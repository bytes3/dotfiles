#!/usr/bin/env python3
"""
markarchive: mark files/folders into groups, then archive them with zstd.

Usage examples:
  # Add one or more paths to a group
  markarchive add -g work notes.txt src/ images/

  # Add without specifying -g -> goes to 'default' group
  markarchive add README.md

  # List groups/contents
  markarchive list            # all groups
  markarchive list -g work    # one group

  # Archive a single group (output name auto if not given)
  markarchive archive -g work

  # Archive ALL groups together
  markarchive archive

Notes:
- Nonexistent paths are warned about and skipped (not added, not archived).
- Database file lives at: ~/.markarchive.json by default (overridable with MARKARCHIVE_DB env var).
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import tarfile
import time
from pathlib import Path
from typing import Dict, List, Optional

# ---------- Configuration ----------
DEFAULT_GROUP = "default"
# “Medium” zstd compression level (zstd levels are typically -5..22; 9 is a reasonable middle ground)
ZSTD_MEDIUM_LEVEL = 9

# Database path (can override via env)
DB_PATH = Path(os.environ.get("MARKARCHIVE_DB", str(Path.home() / ".markarchive.json")))


# ---------- DB helpers ----------
def load_db(path: Path = DB_PATH) -> Dict[str, List[str]]:
    if not path.exists():
        return {"groups": {}}
    try:
        with path.open("r", encoding="utf-8") as f:
            data = json.load(f)
        if not isinstance(data, dict) or "groups" not in data or not isinstance(data["groups"], dict):
            raise ValueError("Corrupt DB structure")
        return data
    except Exception as e:
        print(f"Warning: failed to read DB at {path}: {e}. Recreating.", file=sys.stderr)
        return {"groups": {}}


def save_db(data: Dict[str, List[str]], path: Path = DB_PATH) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    tmp.replace(path)


def normalize_path(p: str) -> str:
    return str(Path(p).expanduser().resolve())


# ---------- Commands ----------
def cmd_add(args: argparse.Namespace) -> int:
    db = load_db()
    groups = db["groups"]

    group = args.group if args.group else DEFAULT_GROUP
    group = group.strip() or DEFAULT_GROUP

    if group not in groups:
        groups[group] = []

    changed = False
    for raw in args.paths:
        abs_path = normalize_path(raw)
        if not Path(abs_path).exists():
            print(f"Warning: path does not exist and will be skipped: {raw}", file=sys.stderr)
            continue
        if abs_path not in groups[group]:
            groups[group].append(abs_path)
            changed = True

    if changed:
        save_db(db)
        print(f"Added to group '{group}'. DB saved at {DB_PATH}")
    else:
        print("Nothing to add (all paths missing or already present).")
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    db = load_db()
    groups = db["groups"]

    if args.group:
        g = args.group.strip()
        if not g:
            g = DEFAULT_GROUP
        paths = groups.get(g, [])
        print(f"[{g}] ({len(paths)} item{'s' if len(paths)!=1 else ''})")
        for p in paths:
            print(" -", p)
        return 0

    if not groups:
        print("No groups yet. Use `markarchive add <path>` to begin.")
        return 0

    for g, paths in groups.items():
        print(f"[{g}] ({len(paths)} item{'s' if len(paths)!=1 else ''})")
        for p in paths:
            print(" -", p)
        print()
    return 0


def stream_tar_to_zstd(paths: List[str], out_file: Path, level: int = ZSTD_MEDIUM_LEVEL) -> None:
    """
    Create a streaming tar and compress with zstd on the fly to out_file (.tar.zst).
    Requires the 'zstandard' module; if not available, falls back to the 'zstd' CLI if present.
    """
    # First try python 'zstandard'
    try:
        import zstandard as zstd  # type: ignore

        with out_file.open("wb") as fout:
            cctx = zstd.ZstdCompressor(level=level)
            with cctx.stream_writer(fout) as zf:
                # tarfile 'w|' = stream mode
                with tarfile.open(fileobj=zf, mode="w|") as tf:
                    for path in paths:
                        p = Path(path)
                        print(f"Archiving: %f", path)
                        if not p.exists():
                            print(f"Warning: path does not exist and will be skipped: {path}", file=sys.stderr)
                            continue
                        tf.add(path, arcname=p.name, recursive=True)
    except ModuleNotFoundError:
        # Fallback: create a temporary .tar then pipe to `zstd`
        import shutil
        import subprocess
        from tempfile import NamedTemporaryFile

        if shutil.which("zstd") is None:
            raise RuntimeError(
                "Neither the 'zstandard' Python module nor the 'zstd' CLI is available.\n"
                "Install with: pip install zstandard   or   apt/brew install zstd."
            )
        with NamedTemporaryFile(prefix="markarchive-", suffix=".tar", delete=False) as ntf:
            tar_path = Path(ntf.name)
        try:
            with tarfile.open(tar_path, mode="w") as tf:
                for path in paths:
                    p = Path(path)
                    if not p.exists():
                        print(f"Warning: path does not exist and will be skipped: {path}", file=sys.stderr)
                        continue
                    tf.add(path, arcname=p.name, recursive=True)

            # Compress with zstd CLI at given level
            # zstd levels are given as -# (e.g. -9)
            cmd = ["zstd", f"-{level}", "-f", "-q", "-o", str(out_file), str(tar_path)]
            subprocess.run(cmd, check=True)
        finally:
            try:
                tar_path.unlink(missing_ok=True)
            except Exception:
                pass


def cmd_archive(args: argparse.Namespace) -> int:
    db = load_db()
    groups = db["groups"]

    # Select which paths to archive
    if args.group:
        g = args.group.strip() or DEFAULT_GROUP
        paths = groups.get(g, [])
        if not paths:
            print(f"No items found in group '{g}'. Nothing to archive.")
            return 0
        label = g
    else:
        # All groups combined
        # Flatten while preserving order (group order not guaranteed; sort for determinism)
        label = "all"
        paths = []
        for g in sorted(groups.keys()):
            paths.extend(groups[g])
        if not paths:
            print("No items recorded in any group. Nothing to archive.")
            return 0

    # Filter out nonexistent with a warning (archive only existing)
    existing = []
    for p in paths:
        if Path(p).exists():
            existing.append(p)
        else:
            print(f"Warning: path does not exist and will be skipped: {p}", file=sys.stderr)

    if not existing:
        print("After filtering missing paths, nothing remains to archive.")
        return 0

    # Decide output name
    ts = time.strftime("%Y%m%d-%H%M%S")
    outname = args.output or f"{label}-{ts}.tar.zst"
    outpath = Path(outname).expanduser().resolve()

    try:
        stream_tar_to_zstd(existing, outpath, level=ZSTD_MEDIUM_LEVEL)
    except Exception as e:
        print(f"Error during archiving: {e}", file=sys.stderr)
        return 1

    print(f"Archive created: {outpath}")
    return 0


# ---------- CLI ----------
def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="markarchive", description="Mark files/folders into groups and archive them with zstd.")
    sub = p.add_subparsers(dest="cmd", required=True)

    pa = sub.add_parser("add", help="Add one or more paths to a group (default group is 'default').")
    pa.add_argument("-g", "--group", help="Group name. If omitted or empty, uses 'default'.")
    pa.add_argument("paths", nargs="+", help="File(s)/folder(s) to add.")
    pa.set_defaults(func=cmd_add)

    pl = sub.add_parser("list", help="List groups or contents of a specific group.")
    pl.add_argument("-g", "--group", help="Group to list. If omitted, lists all groups.")
    pl.set_defaults(func=cmd_list)

    pr = sub.add_parser("archive", help="Archive a group (or all groups) into a .tar.zst at medium compression.")
    pr.add_argument("-g", "--group", help="Group to archive. Omit to archive ALL groups together.")
    pr.add_argument("-o", "--output", help="Output file path (e.g., out.tar.zst). Defaults to '<group>-<timestamp>.tar.zst'.")
    pr.set_defaults(func=cmd_archive)

    return p


def main(argv: Optional[List[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())


#!/usr/bin/env bash
# swaybar status_command with emojis + click handling (fixed json_escape)

set -u

json_escape() {
  # Escape backslashes and quotes, and flatten control chars to spaces.
  # No ANSI-C quoting, no sed newline matching -> portable.
  local s
  # Flatten newlines/tabs/CRs first
  s="$(printf '%s' "$1" | tr '\n\r\t' '   ')"
  # Escape backslash then double-quote
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

dunst_block() {
  local paused icon label
  if command -v dunstctl >/dev/null 2>&1; then
    paused="$(dunstctl is-paused 2>/dev/null || echo false)"
    if [ "$paused" = "true" ]; then
      icon="🔕"; label="DND"
    else
      icon="🔔"; label="Notif"
    fi
    printf '{"name":"dunst","full_text":"%s"}' "$(json_escape "$icon $label")"
  else
    printf '{"name":"dunst","full_text":"%s"}' "$(json_escape "🔔 notif")"
  fi
}

player_block() {
  local status meta icon text
  if command -v playerctl >/dev/null 2>&1; then
    status="$(playerctl status 2>/dev/null || true)"
    case "$status" in
      Playing)
        icon="▶️"
        meta="$(playerctl metadata --format '{{artist}} – {{title}}' 2>/dev/null || echo "")"
        text="$icon $meta"
        ;;
      Paused)
        icon="⏸️"
        meta="$(playerctl metadata --format '{{artist}} – {{title}}' 2>/dev/null || echo "")"
        text="$icon $meta"
        ;;
      *) text="";;
    esac
    printf '{"name":"player","full_text":"%s"}' "$(json_escape "$text")"
  else
    printf '{"name":"player","full_text":""}'
  fi
}

volume_block() {
  local mute vol icon text
  if command -v pactl >/dev/null 2>&1; then
    mute="$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')"
    vol="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oE '[0-9]+%%' | head -n1)"
    [ -z "$vol" ] && vol="--%"
    if [ "$mute" = "yes" ]; then icon="🔇"; else icon="🔊"; fi
    text="$icon $vol"
    printf '{"name":"vol","full_text":"%s"}' "$(json_escape "$text")"
  else
    printf '{"name":"vol","full_text":"%s"}' "$(json_escape "🔊 --%")"
  fi
}

time_block() {
  local text
  text="$(date '+📅 %Y-%m-%d -> %H:%M:%S')"
  printf '{"name":"time","full_text":"%s"}' "$(json_escape "$text")"
}

print_line() {
  printf '[%s,%s]\n' "$(player_block)" "$(time_block)"
}

handle_clicks() {
  local ev
  while IFS= read -r -t 0.05 ev; do
    ev="${ev#, }"
    if printf '%s' "$ev" | grep -q '"name":"dunst"'; then
      if printf '%s' "$ev" | grep -q '"button":1'; then
        command -v dunstctl >/dev/null 2>&1 && dunstctl set-paused toggle >/dev/null 2>&1
      fi
    fi
    if printf '%s' "$ev" | grep -q '"name":"player"'; then
      if printf '%s' "$ev" | grep -q '"button":1'; then
        command -v playerctl >/dev/null 2>&1 && playerctl play-pause >/dev/null 2>&1
      fi
    fi
    if printf '%s' "$ev" | grep -q '"name":"vol"'; then
      if   printf '%s' "$ev" | grep -q '"button":1'; then
        command -v pactl >/dev/null 2>&1 && pactl set-sink-mute @DEFAULT_SINK@ toggle >/dev/null 2>&1
      elif printf '%s' "$ev" | grep -q '"button":4'; then
        command -v pactl >/dev/null 2>&1 && pactl set-sink-volume @DEFAULT_SINK@ +5%% >/dev/null 2>&1
      elif printf '%s' "$ev" | grep -q '"button":5'; then
        command -v pactl >/dev/null 2>&1 && pactl set-sink-volume @DEFAULT_SINK@ -5%% >/dev/null 2>&1
      fi
    fi
  done
}

# i3bar/swaybar JSON header with click events
# (Protocol details: header like { "version": 1, "click_events": true } then a stream of arrays.)
# i3bar/swaybar click events are sent as JSON to stdin. :contentReference[oaicite:2]{index=2}
printf '{ "version": 1, "click_events": true }\n[\n'

first=1
while :; do
  handle_clicks
  if [ $first -eq 1 ]; then first=0; else printf ',\n'; fi
  print_line
  sleep 1
done


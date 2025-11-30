files_to_open=""

for file in $(yadm list); do
  if [[ ! $file =~ \.keep$ && ! $file =~ \.gitkeep$ ]]; then
    files_to_open+="$file "
  fi
done

$EDITOR ~/.zshrc $files_to_open

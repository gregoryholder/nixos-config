set -euo pipefail

file="${1:?missing filename}"
line="${2:-}"

if [[ -d "$file" ]]; then
  nvr --servername "$NVIM_LISTEN_ADDRESS" --nostart --remote +'Oil' "$file"
elif [[ -n "$line" ]]; then
  nvr --servername "$NVIM_LISTEN_ADDRESS" --nostart --remote +"$line" "$file"
else
  nvr --servername "$NVIM_LISTEN_ADDRESS" --nostart --remote "$file"
fi

nvr --servername "$NVIM_LISTEN_ADDRESS" --nostart --remote-send '<Cmd>silent! call jobstart(["wezterm","cli","activate-pane","--pane-id",$WEZTERM_PANE], {"detach": v:true})<CR>'

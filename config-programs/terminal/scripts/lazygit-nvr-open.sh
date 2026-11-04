set -euo pipefail

file="${1:?missing filename}"
line="${2:-}"
if [[ -n "${KITTY_WINDOW_ID:-}" && -n "${KITTY_PID:-}" ]]; then
  socket="${KITTY_LISTEN_ON:-unix:${XDG_CACHE_HOME:-$HOME/.cache}/kitty.sock}"
  if [[ -S "${socket#unix:}-$KITTY_PID" ]]; then
    export KITTY_LISTEN_ON="$socket-$KITTY_PID"
  fi
fi

if [[ -n "${NVIM:-}" ]]; then
  NVIM_LISTEN_ADDRESS="$NVIM"
elif [[ -z "${NVIM_LISTEN_ADDRESS:-}" ]]; then
  if [[ -n "${KITTY_WINDOW_ID:-}" && -n "${KITTY_LISTEN_ON:-}" ]]; then
    tab_id="$(kitten @ --to "$KITTY_LISTEN_ON" ls | python3 __TERMINAL_TAB_ID__)"
    NVIM_LISTEN_ADDRESS="/tmp/nvim-kitty-tab-$UID-$tab_id.sock"
  elif [[ -n "${WEZTERM_PANE:-}" ]]; then
    tab_id="$(wezterm cli list --format json | python3 __TERMINAL_TAB_ID__)"
    NVIM_LISTEN_ADDRESS="/tmp/nvim-wezterm-tab-$tab_id.sock"
  fi
fi

: "${NVIM_LISTEN_ADDRESS:?Neovim server address is unavailable; start Neovim from a configured Kitty or WezTerm tab}"

if [[ -d "$file" ]]; then
  nvr --servername "$NVIM_LISTEN_ADDRESS" --nostart --remote +'Oil' "$file"
elif [[ -n "$line" ]]; then
  nvr --servername "$NVIM_LISTEN_ADDRESS" --nostart --remote +"$line" "$file"
else
  nvr --servername "$NVIM_LISTEN_ADDRESS" --nostart --remote "$file"
fi

if [[ -n "${KITTY_WINDOW_ID:-}" && -n "${KITTY_LISTEN_ON:-}" ]]; then
  editor_window="$(nvr --servername "$NVIM_LISTEN_ADDRESS" --nostart --remote-expr '$KITTY_WINDOW_ID')"
  kitten @ --to "$KITTY_LISTEN_ON" focus-window --match "id:$editor_window"
elif [[ -n "${WEZTERM_PANE:-}" ]]; then
  nvr --servername "$NVIM_LISTEN_ADDRESS" --nostart --remote-send '<Cmd>silent! call jobstart(["wezterm","cli","activate-pane","--pane-id",$WEZTERM_PANE], {"detach": v:true})<CR>'
fi

function nvim() {
  if [[ -n "${NVIM:-}" || ( -z "${KITTY_WINDOW_ID:-}" && -z "${WEZTERM_PANE:-}" ) ]]; then
    command nvim "$@"
    return
  fi

  local arg
  for arg in "$@"; do
    if [[ "$arg" == "--" ]]; then
      break
    fi
    if [[ "$arg" == "--listen" || "$arg" == --listen=* ]]; then
      command nvim "$@"
      return
    fi
  done

  local socket
  socket="$(terminal-nvim listen-address)" || return
  if [[ -n "$socket" ]]; then
    NVIM_LISTEN_ADDRESS="$socket" command nvim --listen "$socket" "$@"
  else
    NVIM_LISTEN_ADDRESS="" command nvim "$@"
  fi
}

# Use one Neovim socket per WezTerm tab so adjacent panes share the same instance.
function __wezterm_tab_nvim_socket() {
  [[ -n "${WEZTERM_PANE:-}" ]] || return 1

  local tab_id
  # Nix replaces this placeholder with the store path of the Python helper.
  tab_id="$(
    wezterm cli list --format json 2>/dev/null | python3 __WEZTERM_TAB_ID__
  )"

  [[ -n "$tab_id" ]] || return 1
  printf '/tmp/nvim-wezterm-tab-%s.sock\n' "$tab_id"
}

function __kitty_tab_nvim_socket() {
  [[ -n "${KITTY_WINDOW_ID:-}" && -n "${KITTY_LISTEN_ON:-}" ]] || return 1

  local tab_id
  tab_id="$(
    kitten @ --to "$KITTY_LISTEN_ON" ls | python3 __KITTY_TAB_ID__
  )" || return 1

  [[ -n "$tab_id" ]] || return 1
  printf '/tmp/nvim-kitty-tab-%s-%s.sock\n' "$UID" "$tab_id"
}

function __set_wezterm_tab_nvim_env() {
  if [[ -n "${KITTY_WINDOW_ID:-}" ]]; then
    if [[ -n "${KITTY_PID:-}" ]]; then
      local socket="${KITTY_LISTEN_ON:-unix:${XDG_CACHE_HOME:-$HOME/.cache}/kitty.sock}"
      if [[ -S "${socket#unix:}-$KITTY_PID" ]]; then
        export KITTY_LISTEN_ON="$socket-$KITTY_PID"
      fi
    fi

    if [[ "${__KITTY_TAB_NVIM_WINDOW:-}" == "$KITTY_WINDOW_ID" && -n "${__KITTY_TAB_NVIM_SOCKET:-}" ]]; then
      export NVIM_LISTEN_ADDRESS="$__KITTY_TAB_NVIM_SOCKET"
      return 0
    fi

    local kitty_sock
    kitty_sock="$(__kitty_tab_nvim_socket)" || return 0
    export __KITTY_TAB_NVIM_SOCKET="$kitty_sock"
    export __KITTY_TAB_NVIM_WINDOW="$KITTY_WINDOW_ID"
    export NVIM_LISTEN_ADDRESS="$kitty_sock"
    return 0
  fi

  # Cache the tab socket per pane.
  if [[ -n "${__WEZTERM_TAB_NVIM_SOCKET:-}" && "${__WEZTERM_TAB_NVIM_PANE:-}" == "${WEZTERM_PANE:-}" ]]; then
    export NVIM_LISTEN_ADDRESS="$__WEZTERM_TAB_NVIM_SOCKET"
    return 0
  fi

  local sock
  sock="$(__wezterm_tab_nvim_socket)" || return 0
  export __WEZTERM_TAB_NVIM_SOCKET="$sock"
  export __WEZTERM_TAB_NVIM_PANE="${WEZTERM_PANE:-}"
  export NVIM_LISTEN_ADDRESS="$sock"
}

function __nvim_server_is_listening() {
  [[ -n "$NVIM_LISTEN_ADDRESS" ]] || return 1
  [[ -S "$NVIM_LISTEN_ADDRESS" ]] || return 1
  nvr --nostart --servername "$NVIM_LISTEN_ADDRESS" --remote-expr '1' >/dev/null 2>&1
}

# Start nvim with a tab-scoped socket only when no server is already attached.
# This allows multiple nvim instances in the same pane/tab.
function nvim() {
  if [[ -n "$NVIM" ]]; then
    command nvim "$@"
    return
  fi

  local explicit_listen=0
  local arg
  for arg in "$@"; do
    if [[ "$arg" == "--listen" || "$arg" == --listen=* ]]; then
      explicit_listen=1
      break
    fi
  done

  if (( ! explicit_listen )); then
    __set_wezterm_tab_nvim_env
  fi

  if (( explicit_listen )) || [[ -z "$NVIM_LISTEN_ADDRESS" ]]; then
    command nvim "$@"
    return
  fi

  if __nvim_server_is_listening; then
    export NVIM_LISTEN_ADDRESS=""
    command nvim "$@"
  else
    command nvim --listen "$NVIM_LISTEN_ADDRESS" "$@"
  fi
}

function lazygit() {
  if [[ -n "${NVIM:-}" ]]; then
    NVIM_LISTEN_ADDRESS="$NVIM" command lazygit "$@"
  else
    __set_wezterm_tab_nvim_env
    command lazygit "$@"
  fi
}

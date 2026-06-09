# Use one Neovim socket per WezTerm tab so adjacent panes share the same instance.
function __wezterm_tab_nvim_socket() {
  [[ -n "$WEZTERM_PANE" ]] || return 1

  local tab_id
  local script_dir="${${(%):-%N}:A:h}"
  tab_id="$(
    wezterm cli list --format json 2>/dev/null | python3 "$script_dir/wezterm-tab-id.py"
  )"

  [[ -n "$tab_id" ]] || return 1
  printf '/tmp/nvim-wezterm-tab-%s.sock\n' "$tab_id"
}

function __set_wezterm_tab_nvim_env() {
  local sock
  sock="$(__wezterm_tab_nvim_socket)" || return 0
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

autoload -Uz add-zsh-hook
add-zsh-hook precmd __set_wezterm_tab_nvim_env
__set_wezterm_tab_nvim_env

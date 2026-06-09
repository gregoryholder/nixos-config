{ ... }:
{
  programs.zsh.initExtra = ''
    # Development environment initialization
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - zsh)"

    # export NVM_DIR="$HOME/.nvm"
    # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
    # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # fnm
    FNM_PATH="/home/dev/.local/share/fnm"
    if [ -d "$FNM_PATH" ]; then
      export PATH="$FNM_PATH:$PATH"
      eval "$(fnm env --shell zsh)"
    fi

    setopt AUTO_PUSHD

    # Smart cd function that uses zoxide
    function cd() {
      if [[ $# -le 1 ]]; then
        __zoxide_z "$@"
      else
        builtin cd "$@"
      fi
    }
    function link_chain(){
      namei $* | awk '$1=="l" || $1=="f:"'
    }

    # Use one Neovim socket per WezTerm tab so adjacent panes share the same instance.
    function __wezterm_tab_nvim_socket() {
      [[ -n "$WEZTERM_PANE" ]] || return 1

      local tab_id
      tab_id="$(
        wezterm cli list --format json 2>/dev/null | python3 -c '
import json
import os
import sys

pane = os.environ.get("WEZTERM_PANE")
if not pane:
    raise SystemExit(1)

try:
    rows = json.load(sys.stdin)
except Exception:
    raise SystemExit(1)

for row in rows:
    if str(row.get("pane_id")) == str(pane):
        tab_id = row.get("tab_id")
        if tab_id is not None:
            print(tab_id)
            raise SystemExit(0)

raise SystemExit(1)
'
      )"

      [[ -n "$tab_id" ]] || return 1
      printf '/tmp/nvim-wezterm-tab-%s.sock\n' "$tab_id"
    }

    function __set_wezterm_tab_nvim_env() {
      local sock
      sock="$(__wezterm_tab_nvim_socket)" || return 0
      export NVIM_LISTEN_ADDRESS="$sock"
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd __set_wezterm_tab_nvim_env
    __set_wezterm_tab_nvim_env
  '';
}

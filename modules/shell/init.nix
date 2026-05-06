{ ... }:
{
  programs.zsh.initExtra = ''
    # Development environment initialization
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - zsh)"

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    setopt AUTO_PUSHD

    # Smart cd function that uses zoxide
    function cd() {
      if [[ $# -le 1 ]]; then
        __zoxide_z "$@"
      else
        builtin cd "$@"
      fi
    }
  '';
}

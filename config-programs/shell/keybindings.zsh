# Use vi mode in zsh and switch cursor shape with the active keymap.
KEYTIMEOUT=1
bindkey -v

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    print -n -- $'\e[2 q' # steady block cursor (normal mode)
  else
    print -n -- $'\e[6 q' # steady beam cursor (insert mode)
  fi
}
zle -N zle-keymap-select

function zle-line-init {
  zle-keymap-select
}
zle -N zle-line-init

function zle-line-finish {
  print -n -- $'\e[6 q'
}
zle -N zle-line-finish

# Keep Ctrl+F accepting autosuggestions in vi insert mode.
bindkey -M viins '^F' forward-char
bindkey -M emacs '^F' forward-char
bindkey -M viins '^U' backward-kill-line

# Keybindings for common terminal actions
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line

bindkey '^?'    backward-delete-char         # Backspace
bindkey '\e[3~' delete-char                  # Del
bindkey '\e[3;5~' delete-char                # sometimes Del, sometimes C-Del
bindkey '\e[2~' overwrite-mode               # Ins

bindkey '^H'      backward-kill-word         # C-Backspace
bindkey '5~'      kill-word                  # C-Del
bindkey '^[[3;5~' kill-word                  # C-Del
bindkey '^[[3^'   kill-word                  # C-Del

bindkey "^[[1;5H" backward-kill-line         # C-Home
bindkey "^[[7^"   backward-kill-line         # C-Home

bindkey "^[[1;5F" kill-line                  # C-End
bindkey "^[[8^"   kill-line                  # C-End

bindkey '^[[1;5C' forward-word               # C-Right
bindkey '^[0c'    forward-word               # C-Right
bindkey '^[[5C'   forward-word               # C-Right

bindkey '^[[1;5D' backward-word              # C-Left
bindkey '^[0d'    backward-word              # C-Left
bindkey '^[[5D'   backward-word              # C-Left

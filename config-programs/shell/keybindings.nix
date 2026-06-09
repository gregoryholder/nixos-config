{ pkgs, lib, ... }:
let
  # ZLE/bindkey definitions kept as Nix data so the generated script stays comment-free.
  bindings = [
    { key = "'^F'"; action = "forward-char"; mode = "-M viins"; }
    { key = "'^F'"; action = "forward-char"; mode = "-M emacs"; }
    { key = "'^U'"; action = "backward-kill-line"; mode = "-M viins"; }
    { key = "\"^[[H\""; action = "beginning-of-line"; }
    { key = "\"^[[F\""; action = "end-of-line"; }
    { key = "'^?'"; action = "backward-delete-char"; }
    { key = "'\\e[3~'"; action = "delete-char"; }
    { key = "'\\e[3;5~'"; action = "delete-char"; }
    { key = "'\\e[2~'"; action = "overwrite-mode"; }
    { key = "'^H'"; action = "backward-kill-word"; }
    { key = "'5~'"; action = "kill-word"; }
    { key = "'^[[3;5~'"; action = "kill-word"; }
    { key = "'^[[3^'"; action = "kill-word"; }
    { key = "\"^[[1;5H\""; action = "backward-kill-line"; }
    { key = "\"^[[7^\""; action = "backward-kill-line"; }
    { key = "\"^[[1;5F\""; action = "kill-line"; }
    { key = "\"^[[8^\""; action = "kill-line"; }
    { key = "'^[[1;5C'"; action = "forward-word"; }
    { key = "'^[0c'"; action = "forward-word"; }
    { key = "'^[[5C'"; action = "forward-word"; }
    { key = "'^[[1;5D'"; action = "backward-word"; }
    { key = "'^[0d'"; action = "backward-word"; }
    { key = "'^[[5D'"; action = "backward-word"; }
  ];

  renderBinding =
    binding:
    let
      mode = if binding ? mode then "${binding.mode} " else "";
    in
      "bindkey ${mode}${binding.key} ${binding.action}";

  keybindingsScript = pkgs.writeText "keybindings.zsh" (
    lib.concatStringsSep "\n" (
      [
        "KEYTIMEOUT=1"
        "bindkey -v"
        ""
        "function zle-keymap-select {"
        "  if [[ $KEYMAP == vicmd ]]; then"
        "    print -n -- $'\\e[2 q'"
        "  else"
        "    print -n -- $'\\e[6 q'"
        "  fi"
        "}"
        "zle -N zle-keymap-select"
        ""
        "function zle-line-init {"
        "  zle-keymap-select"
        "}"
        "zle -N zle-line-init"
        ""
        "function zle-line-finish {"
        "  print -n -- $'\\e[6 q'"
        "}"
        "zle -N zle-line-finish"
        ""
      ]
      ++ map renderBinding bindings
    )
  );
in
{
  programs.zsh.initExtra = ''
    source ${keybindingsScript}
  '';
}

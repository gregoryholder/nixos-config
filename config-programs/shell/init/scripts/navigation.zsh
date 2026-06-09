setopt AUTO_PUSHD

# Smart cd function that uses zoxide
function cd() {
  if [[ $# -le 1 ]]; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi
}

function link_chain() {
  namei "$@" | awk '$1=="l" || $1=="f:"'
}

###
### Auto update and reload configuration.
###

DOT_LOG=false
dot-log() { [ "$DOT_LOG" = true ] && echo "$$) DOT_ID=$DOT_ID $1" >> "/tmp/dot.log" ; }

dot-up() {
  pushd $DOTFILES > /dev/null

  echo ">>>"
  echo ">>> Upgrade oh-my-zsh"
  echo ">>>"

  "$ZSH/tools/upgrade.sh"

  echo ">>>"
  echo ">>> Upgrade dotfiles (use --all to also update subrepos)"
  echo ">>>"

  if [ "$(git diff --stat)" != '' ] || [ "$(git current-branch)" != 'main' ]; then
    echo "Invalid $DOTFILES environment, stop update"
    echo "Maybe you're looking for dot-reload"
    popd > /dev/null
    return 1
  fi

  git pull origin main

  if [ "$1" = '--all' ]; then
    git subrepo pull --all
    git push origin main
  fi

  popd > /dev/null
  dot-reload
}

dot-reload() {
  if [ -z "$DOT_PWD_FILE" ]; then
    echo "Not in a dotfiles session" 1>&2
    return 1
  fi
  dot-log "dot-reload"
  echo $PWD > "$DOT_PWD_FILE"
  exit 242
}

dot_new_session() {
  local ret=242
  export DOT_ID="$$"
  export DOT_PWD_FILE="$DOTCACHE/$DOT_ID"
  while [ $ret = 242 ]; do
    # Restore the previous working directory.
    if [ -f "$DOT_PWD_FILE" ]; then
      export DOT_PWD="$(cat $DOT_PWD_FILE)"
      dot-log "dot_new_session restore DOT_PWD=$DOT_PWD"
      rm -f "$DOT_PWD_FILE"
    else
      dot-log "dot_new_session PWD=$PWD"
      export DOT_PWD="$PWD"
    fi
    # Start a new session and consider its return code.
    "$SHELL"
    ret=$?
  done
  rm -f "$DOT_PWD_FILE"
}

dot_main() {
  if [ -z $DOT_ID ]; then
    dot_new_session
    exit $?
  else
    dot-log "dot-main go back to $DOT_PWD from $PWD"
    cd "$DOT_PWD"
    echo # Add an empty line between sessions.
  fi

  if $DOTFILES/bin/check_update dotfiles; then
    dot-up --all
  fi
}
dot_main

unset -f dot_main dot_new_session

if command -v code > /dev/null; then
  alias vscode="$(command -v code)"
  alias code="DOT_ID= DOT_PWD= vscode"
fi

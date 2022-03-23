###
### Auto update and reload configuration.
###

dot-reload() {
  if [ -z "$DOT_PWD_FILE" ]; then
    echo "Not in a dotfiles session" 1>&2
    return 1
  fi
  echo $PWD > "$DOT_PWD_FILE"
  echo # Add an empty line between sessions.
  exit 242
}

dot-up() {
  cd $DOTFILES

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

dot_new_session() {
  local ret=242
  export DOT_ID=$(date +%s)
  export DOT_PWD_FILE="$DOTCACHE/$DOT_ID"
  while [ $ret = 242 ]; do
    # Restore the previous working directory.
    if [ -f "$DOT_PWD_FILE" ]; then
      export DOT_PWD="$(cat $DOT_PWD_FILE)"
      rm -f "$DOT_PWD_FILE"
    else
      export DOT_PWD="$PWD"
    fi
    # Start a new session and consider its return code.
    zsh
    ret=$?
  done
  rm -f "$DOT_PWD_FILE"
}

# Start a new session if not in an existing one
if [ -z $DOT_ID ]; then
  dot_new_session
  exit $?
else
  # Or go back to the previous working directory.
  cd "$DOT_PWD"
fi
unset dot_new_session

##
## Update part
##

# Welcome output
echo "     ~~~~~~~~ Welcome $USER@$HOST :3 ~~~~~~~~"
echo "+ $(uname -a)"
echo "+ $(uptime)"

if $DOTFILES/bin/check_update dotfiles; then
  dot-up --all
fi

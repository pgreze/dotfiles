###
### Auto update configuration.
###

function dotfiles_update {
  if [[ $(git diff --stat) != '' ]] || [[ $(git current-branch) != 'master' ]]; then
    echo "Invalid $DOTFILES environment, stop update"
    return 1
  fi

  pushd $DOTFILES
  git pull origin master
  git subrepo pull --all
  git push origin master
  popd
}

if $DOTFILES/bin/check_update dotfiles; then
  dotfiles_update
fi

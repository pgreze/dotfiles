###
### Auto update configuration.
###

if $DOTFILES/bin/check_update dotfiles; then
  $DOTFILES/bin/dot-up --all
fi

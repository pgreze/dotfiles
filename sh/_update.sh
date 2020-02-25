###
### Auto update configuration.
###

if $DOTFILES/bin/check_update dotfiles; then
  $DOTFILES/bin/dotfiles_update --all
fi

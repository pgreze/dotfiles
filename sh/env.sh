###
### General environment configuration.
###

command -v code > /dev/null && export EDITOR=code || export EDITOR=vim

if [ -e $DOTFILES/local.sh ]; then
  source "$DOTFILES/local.sh"
else
  echo "Specify $DOTFILES/local.sh for your local specific config"
fi

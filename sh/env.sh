###
### General environment configuration.
###

# EDITOR
command -v code > /dev/null && export EDITOR=code || export EDITOR=vim

# Add ~/bin to PATH
[ -d "$HOME/bin" ] && export PATH="$PATH:$HOME/bin"

# Load ~/.my/local.sh
if [ -e $DOTFILES/local.sh ]; then
  source "$DOTFILES/local.sh"
else
  echo "Creates $DOTFILES/local.sh for your local specific config"
  touch "$DOTFILES/local.sh"
fi

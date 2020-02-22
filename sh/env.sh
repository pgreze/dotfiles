###
### General environment configuration.
###

# Add internal bin folder
export PATH="$DOTFILES/bin:$PATH"

command -v code > /dev/null && export EDITOR=code || export EDITOR=vim

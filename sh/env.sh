###
### General environment configuration.
###

# EDITOR
command -v code > /dev/null && export EDITOR=code || export EDITOR=vim

# Create local/ files if not found
for file in zshrc zshenv; do
  [ -d "$DOTFILES/local" ] || mkdir -p "$DOTFILES/local"
  target="$DOTFILES/local/$file"
  if [ ! -f "$target" ]; then
    touch "$target"
    echo "Created this machine only $target"
  fi
done

# Load this machine only configuration.
source "$DOTFILES/local/zshrc"

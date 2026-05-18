###
### Shell configuration root file, loading other ones.
###

export DOTFILES="$HOME/.my"

export DOTCACHE="$DOTFILES/.cache"
mkdir -p "$DOTCACHE"

# Import all configuration files
for file in $DOTFILES/sh/*.sh; do
    source "$file"
done

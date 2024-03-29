###
### Shell configuration root file, loading other ones.
###

export DOTFILES="$HOME/.my"
alias dot-cd="cd $DOTFILES"

export DOTCACHE="$DOTFILES/.cache"
mkdir -p "$DOTCACHE"

export PATH="$DOTFILES/bin:$PATH"

# Import all configuration files
for file in $DOTFILES/sh/*.sh; do
    source "$file"
done

###
### Shell configuration root file, loading other ones.
###

export DOTFILES="$HOME/.my"

# Welcome output
echo "     ~~~~~~~~ Welcome $USER@$HOST :3 ~~~~~~~~"
echo "+ $(uname -a)"
echo "+ $(uptime)"

# Import all configuration files
for file in $(ls $DOTFILES/sh/*.sh); do
    source "$file"
done
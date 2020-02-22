##
## Root file of common shell configuration.
## This should be a small file, importing specialised scripts.
##

# Welcome output
echo "     ~~~~~~~~ Welcome $USER@$HOST :3 ~~~~~~~~"
echo "+ $(uname -a)"
echo "+ $(uptime)"

# Import all configuration files
for f in $(ls "$HOME/.my/sh/"); do
    source "$HOME/.my/sh/$f"
done

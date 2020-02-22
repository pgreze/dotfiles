###
### Shell configuration root file, loading other ones.
###

# Welcome output
echo "     ~~~~~~~~ Welcome $USER@$HOST :3 ~~~~~~~~"
echo "+ $(uname -a)"
echo "+ $(uptime)"

# Import all configuration files
for file in $(ls $HOME/.my/sh/*.sh); do
    source "$file"
done

##
## Welcome output
##

echo "     ~~~~~~~~ $USER@$(hostname) ~~~~~~~~"
# Shorter alternative to "uname -a", see --help for details
echo "$(uname -srmpo)"
echo "$(uptime)"

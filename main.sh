##
## Root file of common shell configuration.
## This should be a small file, importing specialised scripts.
##

function command_exists {
    # Note: &> redirect all output
    type "$1" &> /dev/null
}

# Usage: source_if_exists [condition.file] script.sh
function source_if_exists {
    [ -z $2 ] && file=$1 || file=$2
    # Test if file or symbolic link exists
    [ -e $1 ] || [ -L $1 ] && source $file
}

# Welcome output
echo "     ~~~~~~~~ Welcome $USER@$HOST :3 ~~~~~~~~"
echo "+ $(uname -a)"
echo "+ $(uptime)"

# Configure env
source "$HOME/.my/env.sh"

# Import main resources
source "$HOME/.my/common.sh"

if [[ "$(uname)" == 'Darwin' ]]; then
    source "$HOME/.my/osx.sh"
fi

# Specific host conf if exists
source_if_exists "$HOME/.my/local.sh" ||
    echo ">> You can specify $HOME/.my/local.sh for local configuration"

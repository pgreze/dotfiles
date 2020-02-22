###
### First imported configuration,
### put here essential tools or required by next scripts.
###

# Add internal bin folder
export PATH="$HOME/.my/bin:$PATH"

function command_exists {
    # Note: &> redirect all output
    type "$1" &> /dev/null
}

# Editor
export EDITOR="/usr/bin/vim"
# Warning: if Visual studio code is not from homebrew and PATH injected in local.sh,
# This test will probably be wrong at this time
command_exists code && export EDITOR=code

# Usage: source_if_exists [condition.file] script.sh
function source_if_exists {
    [ -z $2 ] && file=$1 || file=$2
    # Test if file or symbolic link exists
    [ -e $1 ] || [ -L $1 ] && source $file
}

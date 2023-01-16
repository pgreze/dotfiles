##
## https://sdkman.io/ config
##
## This is a tool for managing parallel versions of multiple Software Development Kits on most Unix based systems.
## It provides a convenient Command Line Interface (CLI) and API for installing, switching, removing and listing Candidates.
##
## Install with: curl -s "https://get.sdkman.io" | bash
##

if [ -d "$HOME/.sdkman" ]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

sdk-howto() {
    echo "
https://sdkman.io/usage

# Use

sdk use java 11.0.15-zulu
sdk default java 11.0.15-zulu

sdk current
sdk current java

# Install

sdk list [java]

sdk install [java] [version]
    autocompletion is working 👍
sdk upgrade kotlin

sdk offline [enable|disable]

sdk version
sdk selfupdate (force) # add 'force' to reinstall
"
}

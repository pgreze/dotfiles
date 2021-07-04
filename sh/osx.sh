###
### OSX configuration
###

export PATH="/usr/local/opt/curl/bin:$PATH"

alias restart_backup_and_sync="killall Backup\ and\ Sync && sleep 10 && open -a /Applications/Backup\ and\ Sync.app"

function osx_notification {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 [text...]"
        echo ""
        echo "This will display a Notification Center notification with provided text."
        echo "See https://goo.gl/cEE8Tc for more details"
    else
        osascript -e "display notification \"$*\" with title \"Script alert\" sound name \"Glass.aiff\""
    fi
}

function xcode {
    if [ $# -eq 0 ]; then
        echo "Usage: xcode /Applications/XcodeXX"
        echo "Current version: $(xcode-select -p)\n"
        echo "Available versions:"
        for xc in /Applications/Xcode*;do echo "xcode $xc";done
    else
        sudo xcode-select -s "$1/Contents/Developer"
    fi
}

function osx_init {
    # Python
    export PIP_DOWNLOAD_CACHE='/var/tmp/pip-cache';

    # Setup brew cask to install into /Applications folder.
    export HOMEBREW_CASK_OPTS='--appdir=/Applications';

    # Promote gnu tools from homebrew
    local OPT_PATH="$(brew --prefix)/opt"
    if [ -d "$OPT_PATH/coreutils" ]; then
        PATH="$OPT_PATH/coreutils/libexec/gnubin:$PATH"
        # Fix ls alias when gnu utils are used
        alias ls='ls --color'
    fi
    if [ -d "$OPT_PATH/grep" ]; then
        PATH="$OPT_PATH/grep/libexec/gnubin:$PATH"
    fi

    # Fix encoding annoyances with less. See configuration with "locale" command.
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8

    # Colored ls with yellow for directories
    # Not working with homebrew ls :/
    export CLICOLOR=1
    export LSCOLORS=dxfxcxdxbxegedabagacad
}

if [[ "$(uname)" == 'Darwin' ]]; then
    osx_init
fi

unset -f osx_init

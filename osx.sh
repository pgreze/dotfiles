##
## Common OSX configuration
##

# Python
export PIP_DOWNLOAD_CACHE='/var/tmp/pip-cache';

# Setup brew cask to install into /Applications folder.
export HOMEBREW_CASK_OPTS='--appdir=/Applications';

# Promote gnu utils from homebrew
if [ -d /usr/local/opt/coreutils ];then
    PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    # Fix ls alias when gnu utils are used
    alias ls='ls --color'
fi

# Fix encoding annoyances with less. See configuration with "locale" command.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Colored ls with yellow for directories
# Not working with homebrew ls :/
export CLICOLOR=1
export LSCOLORS=dxfxcxdxbxegedabagacad

###
### Bash configuration
###

if [ -d "$HOME/bin" ]; then
    export PATH="$PATH:$HOME/bin"
fi

# See https://itnext.io/upgrading-bash-on-macos-7138bd1066ba
if file /usr/local/bin/bash > /dev/null && \
    [ $(which -a bash | grep /usr/local/bin/bash | wc -l) -ne 0 ] && \
    [ $(grep /usr/local/bin/bash /etc/shells | wc -l) -eq 0 ]; then
    echo "Consider adding the non default bash as available shell with:"
    echo "sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'"
    echo "See https://apple.stackexchange.com/a/291290"
fi

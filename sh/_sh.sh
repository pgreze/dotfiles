###
### Shell configuration
###

# Temporary fix when chsh was done without reboot
case $SHELL in
  */zsh)  [ ! -z $BASH_VERSION ] && NEW_SHELL=$(command -v bash) ;;
  */bash) [ ! -z $ZSH_VERSION ] && NEW_SHELL=$(command -v zsh) ;;
  *)      echo "Unsupported shell, cannot load starship."
esac
if [ ! -z "$NEW_SHELL" ]; then
    echo "Fix SHELL=$SHELL to $NEW_SHELL"
    export SHELL="$NEW_SHELL"
    unset NEW_SHELL
fi

# See https://itnext.io/upgrading-bash-on-macos-7138bd1066ba
if file /usr/local/bin/bash > /dev/null && \
    [ $(which -a bash | grep /usr/local/bin/bash | wc -l) -ne 0 ] && \
    [ $(grep /usr/local/bin/bash /etc/shells | wc -l) -eq 0 ]; then
    echo "Consider adding the non default bash as available shell with:"
    echo "sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'"
    echo "See https://apple.stackexchange.com/a/291290"
fi

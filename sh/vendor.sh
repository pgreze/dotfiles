###
### Includes third party plugins in vendor/ folder.
###

dot-vendor-update() {
    pushd $DOTFILES > /dev/null
    git subrepo pull -a
    popd > /dev/null
}

export PATH="$DOTFILES/vendor/gng/bin/:$PATH"

source "$DOTFILES/vendor/git-subrepo/.rc"

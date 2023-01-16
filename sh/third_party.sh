###
### Includes third party plugins.
###

THIRD_PARTY_DIR="$DOTFILES/third_party"

export PATH="$THIRD_PARTY_DIR/gdub/bin/:$PATH"
source "$THIRD_PARTY_DIR/git-subrepo/.rc"

# https://github.com/nvbn/thefuck
if command -v fuck > /dev/null; then
  eval $(thefuck --alias)
fi

unset THIRD_PARTY_DIR

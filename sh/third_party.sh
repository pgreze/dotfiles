###
### Includes third party plugins.
###

THIRD_PARTY_DIR="$DOTFILES/third_party"

export PATH="$THIRD_PARTY_DIR/gdub/bin/:$PATH"
source "$THIRD_PARTY_DIR/git-subrepo/.rc"

unset THIRD_PARTY_DIR

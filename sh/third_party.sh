###
### Includes third party plugins.
###

THIRD_PARTY_DIR="$DOTFILES/third_party"

export PATH="$THIRD_PARTY_DIR/gdub/bin/:$PATH"
source "$THIRD_PARTY_DIR/git-subrepo/.rc"

if command -v fuck > /dev/null; then
  eval $(thefuck --alias)
else
  echo "Missing fuck, install with brew or pip install thefuck."\
      "See https://github.com/nvbn/thefuck"
fi

unset THIRD_PARTY_DIR

###
### Ruby configuration.
###

# Load rbenv if available
# https://github.com/rbenv/rbenv
[ -e $HOME/.rbenv ] && export PATH="$HOME/.rbenv/bin:$PATH"
if command -v rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

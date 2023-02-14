###
### Go configuration
###

# If installed from official installer
[ -d /usr/local/go/bin/ ] && export PATH="/usr/local/go/bin/:$PATH"

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

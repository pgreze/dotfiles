###
### New shiny Rust/Go based CLI
###

# https://github.com/ogham/exa
if command -v exa > /dev/null; then
    alias l="exa -la"
    alias ls="exa"
elif [[ "$(uname)" == 'Darwin' ]]; then
    echo "TODO: brew install exa"
else
    echo "TODO: sudo apt install exa"
fi

# https://github.com/sharkdp/bat
if command -v bat > /dev/null; then
    alias catt="$(which cat)"
    alias cat=bat
    alias less=bat
elif command -v batcat > /dev/null; then
    alias catt="$(which cat)"
    alias cat=batcat
    alias less=batcat
elif [[ "$(uname)" == 'Darwin' ]]; then
    echo "TODO: brew install bat"
else
    echo "TODO: sudo apt install bat"
fi

# https://github.com/dalance/procs
if command -v procs > /dev/null; then
    alias pss="$(which ps)"
    alias ps=procs
elif [[ "$(uname)" == 'Darwin' ]]; then
    echo "TODO: brew install procs"
else
    # Fedora: sudo dnf install procs
    # https://lindevs.com/install-procs-on-ubuntu
    echo "TODO: install_proc"
    install_procs() {
        PROCS_VERSION=$(curl -s "https://api.github.com/repos/dalance/procs/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
        sudo wget -O /usr/local/bin/procs.gz "https://github.com/dalance/procs/releases/download/v${PROCS_VERSION}/procs-v${PROCS_VERSION}-x86_64-linux.zip"
        sudo gunzip /usr/local/bin/procs.gz
        sudo chmod +x /usr/local/bin/procs
        echo ">> procs $PROCS_VERSION successfully installed"
        unset -f install_procs
    }
fi

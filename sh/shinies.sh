###
### New shiny Rust/Go based CLI
###

alias mann="$(which man)"
man() {
    echo "Override man with navi https://github.com/denisidoro/navi"
    navi --query "$1"
}

# https://github.com/ogham/exa
alias l="exa -la"
alias ls="exa"

alias pss="$(which ps)"
ps() {
    echo "Override ps with procs https://github.com/dalance/procs"
    procs "$@"
}

# https://github.com/sharkdp/bat
alias catt="$(which cat)"
alias cat=bat
alias less=bat

alias grepp="$(which grep)"
ps() {
    echo "Override grep with rg https://github.com/BurntSushi/ripgrep"
    rg "$@"
}

# Shiny tools I have not promoted:
# https://github.com/bootandy/dust like ncdu but with percent
# https://github.com/imsnif/bandwhich sudo listen all network calls
# 
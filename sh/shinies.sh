###
### New shiny Rust/Go based CLI
###

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

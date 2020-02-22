###
### Git configuration
###

unalias g
unalias gg
alias gs='git st'
alias gd='git diff'
alias gg='git lg'
alias spull='git spull'
alias gcf='git commit --fixup'
alias gcaf='git commit -a --fixup'

function psed {
    # https://stackoverflow.com/a/12056944
    if [[ $# < 2 ]] ; then
        echo "Usage: $0 \"search_reg\" \"replace_reg\" [\"<pathspec>\"...]"
        return 1
    fi
    local search_reg="$1"
    local replace_reg="$2"
    local pathspecs="${@:3}"
    git grep --null --full-name --name-only --perl-regexp -e "$search_reg" $pathspecs | xargs -0 perl -i -p -e "s:$search_reg:$replace_reg:g"
}

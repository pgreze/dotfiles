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
alias gdm='git diff master'

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

# Common workflow after a PR was merged
function pr_merged {
    local base_branch="${1:-master}"
    local current_branch="$(git rev-parse --abbrev-ref HEAD)"
    if [ $(echo "$current_branch" | wc -l) != 1 ]; then
        echo "More than 1 current branch found: $current_branch" 1>&2
        return 1
    elif [ "$current_branch" = "$base_branch" ]; then
        echo "Already on the base branch ($base_branch)" 1>&2
        return 1
    fi
    git checkout "$base_branch"
    git pull origin "$base_branch"
    git branch -D "$current_branch"
}

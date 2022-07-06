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
alias gdm='git diff $(git_main_branch)'
alias grbi='git rebase -i --autosquash'
alias gri='git rebase -i --autosquash'

alias initial_commit="gcmsg \"Initial commit 🚀\""
alias wip="gcmsg \"WIP 🛠\""

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
    local base_branch="${1:-$(git_main_branch)}"
    local current_branch="$(git_current_branch)"
    if [ $(echo "$current_branch" | wc -l) != 1 ]; then
        echo "More than 1 current branch found: $current_branch" 1>&2
        return 1
    elif [ "$current_branch" = "$base_branch" ]; then
        echo "Already on the base branch ($base_branch)" 1>&2
        return 2
    fi
    git checkout "$base_branch"
    git pull origin "$base_branch"
    git fetch -p origin
    git branch -D "$current_branch"
}

function gclone {
    if [ -z "$1" ]; then
        echo 2>&1 "Usage: $0 git@remote:user/repo.git"
        echo 2>&1 "Usage: $0 user repo"
        echo 2>&1
        echo 2>&1 "This command is cloning a git repo AND cd to the newly created directory."
        return 0
    elif [ ! -z "$2" ]; then
        local repo="git@github.com:$1/$2.git"
    else
        local repo="$1"
    fi
    # Clone repository.
    LOGS="$(mktemp)"
    git clone --progress "${repo}" 2>&1 | tee $LOGS
    # Resolve created folder and move in.
    FOLDER=$(head -1 $LOGS | cut -d\' -f2)
    if [ -z "$FOLDER" ]; then
        echo 2>&1 "Could not resolve output directory"
        return 1
    fi
    echo
    echo "cd $(pwd)/$FOLDER"
    cd $FOLDER
    rm $LOGS > /dev/null
}

git_diff_count() {
    [ -z "${1:-}" ] && echo 2>&1 "Usage: $0 target-branch [base-branch]" && return 1
    local base_branch="$1"
    local target_branch="${2:-HEAD}"

    local common_ancestor=$(git merge-base $base_branch $target_branch)
    local target_count=$(git rev-list --count $target_branch)
    local common_ancestor_count=$(git rev-list --count $common_ancestor)
    echo $(( $target_count - $common_ancestor_count ))
}

alias grv="git review"
_git_review() {
  __gitcomp_nl "$(__git_refs)"
}

alias bfm="git bfm"
_git_bfm() {
  __gitcomp_nl "$(__git_refs)"
}

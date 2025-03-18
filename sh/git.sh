###
### Git configuration
###

unalias g gg 2&>/dev/null
alias gs='git st'
alias gd='git diff'
alias gg='git lg'
alias spull='git spull'
alias gcf='git commit --fixup'
alias gcaf='git commit -a --fixup'
alias gdm='git diff $(git_main_branch)'
alias grbi='git rebase -i --autosquash'
alias gri='git rebase -i --autosquash'
alias gfom='git_main_branch | while read br; do gfo -v "$br:$br";done'
alias grbmm='git_main_branch | while read br; do gfo -v "$br:$br" && git rebase "$br";done'

alias initial_commit="gcmsg 'Initial commit 🚀'"
alias wip="gcmsg 'WIP 🛠'"
alias empty_commit="gcmsg 'Empty commit 🫙' --allow-empty"
alias rerun_ci="gcmsg 'Re-run CI 💸' --allow-empty"

git_branch_from_main() {
  [ -z "${1:-}" ] && echo 2>&1 "Usage: $0 [new-branch]" && return 1
  local new_branch="$1"
  local base_branch="$(git_main_branch)"
  printf "Create $new_branch from $base_branch\n\n"
  git fetch origin "$base_branch"
  echo
  git checkout -b "$1" "origin/$base_branch"
}
alias gbfm=git_branch_from_main

git_diff_count() {
    [ -z "${1:-}" ] && echo 2>&1 "Usage: $0 target-branch [base-branch]" && return 1
    local base_branch="$1"
    local target_branch="${2:-HEAD}"

    local common_ancestor=$(git merge-base $base_branch $target_branch)
    local target_count=$(git rev-list --count $target_branch)
    local common_ancestor_count=$(git rev-list --count $common_ancestor)
    echo $(( $target_count - $common_ancestor_count ))
}

gclone() { . $DOTFILES/bin/_gclone ; }

# Autocompletion for separate binaries.
alias grv="git review"
_git_review() {
  __gitcomp_nl "$(__git_refs)"
}

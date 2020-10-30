###
### Brew configuration
###

# Inspired by https://github.com/Homebrew/homebrew-cask/blob/master/CONTRIBUTING.md#adding-a-cask
brew_checkout() {
    cd $(brew --repository)/Library/Taps/homebrew/homebrew-cask
    local github_user=$(whoami)
    if [ $(git remote show | grep "$github_user" | wc -l) = 0 ]; then
        git remote add "$github_user" "git@github.com:${github_user}/homebrew-cask.git"
    fi
    echo "Contributing guide:"
    echo "  https://github.com/Homebrew/homebrew-cask/blob/master/CONTRIBUTING.md#adding-a-cask"
    echo "To add a new cask, see:"
    echo "  https://github.com/Homebrew/homebrew-cask/blob/master/doc/development/adding_a_cask.md"
    echo "To bump a cask version, use:"
    echo "  brew bump-cask-pr --version <new_version> <outdated_cask>"
}

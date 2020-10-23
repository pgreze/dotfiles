#!/usr/bin/env bash
###
### Install dotfiles environment.
###

# Install oh-my-zsh
[ -d ~/.oh-my-zsh ] || (
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
)

# Install homebrew
[[ "$(uname)" == 'Darwin' ]] && (type brew &> /dev/null ||
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
)

if [ -d $HOME/.my ];then
    echo "dotfiles already found..."
    exit 1
fi

git clone --recursive https://github.com/pgreze/dotfiles ~/.my

# Go to dotfiles directory
pushd ~/.my
# And link all ./exports/* -> ~/.*
echo ">> Export dotfiles from $PWD"
prefix=$(date +%s)
for i in export/*;do
    abspath="$PWD/$i"
    target="$HOME/.${i##*/}"

    if [ -e "$target" ] || [ -L "$target" ];then
        backup=/tmp/"$prefix-${i##*/}"
        echo "Moving $target to $backup"
        mv "$target" "$backup"
    fi

    echo "$abspath -> $target"
    ln -s "$abspath" "$target"
done
# Finish with our custom theme
rm -f "$HOME/.oh-my-zsh/themes/pgreze.zsh-theme"
ln -s "$PWD/pgreze.zsh-theme" "$HOME/.oh-my-zsh/themes/"

popd
echo ">> dotfiles installed :D"

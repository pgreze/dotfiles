#!/usr/bin/env bash

THIS_FILE="$(realpath $0)"
THIS_FOLDER="$(dirname "$THIS_FILE")"
MY_FOLDER="$HOME/.my"

# Install oh-my-zsh
[ -d "$HOME/.oh-my-zsh" ] || (
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
)

# Link current folder to ~/.my
if [ "$THIS_FOLDER" = "$MY_FOLDER" ]; then
    echo "Clone dotfiles in a folder like ~/git/pgreze/dotfiles"
    exit 1
elif [ -d "$MY_FOLDER" ]; then
    echo "$MY_FOLDER already found..."
    exit 1
fi

ln -s "$THIS_FOLDER" "$MY_FOLDER"

# Link all ./exports/* as ~/.*
echo ">> Export dotfiles from $PWD"
prefix=$(date +%s)
pushd ~/.my
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
popd

# Finish with our custom theme
rm -f "$HOME/.oh-my-zsh/themes/pgreze.zsh-theme"
ln -s "$PWD/pgreze.zsh-theme" "$HOME/.oh-my-zsh/themes/"

echo ">> dotfiles installed :D"

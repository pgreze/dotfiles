#!/usr/bin/env bash

THIS_FILE="$(realpath $0)"
THIS_FOLDER="$(dirname "$THIS_FILE")"
DOTFILES="$HOME/.my"

# Install oh-my-zsh
[ -d "$HOME/.oh-my-zsh" ] || (
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
)

# Link current folder to ~/.my
if [ "$THIS_FOLDER" = "$DOTFILES" ]; then
    echo "Clone dotfiles in a folder like ~/git/pgreze/dotfiles"
    exit 1
elif [ -d "$DOTFILES" ]; then
    echo "$DOTFILES already found..."
    exit 1
fi

ln -s "$THIS_FOLDER" "$DOTFILES"

# Link all ./export/* as ~/.*
echo ">> Export dotfiles from $THIS_FOLDER"
EXPORT_VERBOSE=1 . "$DOTFILES/sh/export.sh"

echo ">> dotfiles installed :D"

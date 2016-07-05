
# My precious #

The purpose of this project is to build **my precious** shell from scratch.

Installation:

```bash
## oh-my-zsh (https://github.com/robbyrussell/oh-my-zsh)
curl -L http://install.ohmyz.sh | sh

## OSX commands
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew install coreutils findutils autojump gcc git irssi latex2rtf mkvtoolnix ncdu tmux tree wget htop rename git-flow
cmake ffmpeg
brew cask doctor
brew cask install java
brew cask install android-file-transfer dropbox mplayerx skype qlmarkdown
brew cask install the-unarchiver libreoffice electrum virtualbox cyberduck

# ANDROID DEV
# android-studio-bundle: android-studio + sdk
brew install android-sdk android-ndk
brew cask install android-studio genymotion

## my-precious install
git clone https://github.com/pgreze/dotfiles ~/.my
~/.my/init
```

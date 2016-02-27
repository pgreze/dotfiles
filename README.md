
# My precious #

The purpose of this project is to build **my precious** shell from scratch.

Installation:

```bash
## oh-my-zsh (https://github.com/robbyrussell/oh-my-zsh)
curl -L http://install.ohmyz.sh | sh

## OSX commands
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew install coreutils findutils autojump cmake ffmpeg gcc git go irssi latex2rtf mkvtoolnix ncdu tmux tree wget htop rename git-flow
brew install Caskroom/cask/java caskroom/cask/brew-cask

brew cask doctor
brew cask install vlc android-file-transfer dropbox mplayerx vlc skype alfred iterm2 spotify
brew cask install electrum libreoffice virtualbox cyberduck chromium the-unarchiver tunnelblick
brew cask install qlmarkdown flash
# alternative versions
brew tap caskroom/versions
brew cask install firefox-beta sublime-text3 keepassx0

# ANDROID DEV
# android-studio-bundle: android-studio + sdk
brew install android-sdk android-ndk
brew cask install android-studio genymotion

## my-precious install
git clone https://github.com/pgreze/dotfiles ~/.my
~/.my/init
```

# Dependencies #

- [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
- [autojump](https://github.com/joelthelion/autojump)

# dotfiles

Another dotfiles project.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/pgreze/dotfiles/master/init | sh
```

Homebrew:

```bash
brew doctor
brew install coreutils findutils wget rename tree ncdu htop autojump tmux
brew install latex2rtf mkvtoolnix irssi ffmpeg
brew install git git-flow git-subrepo gcc cmake
```

Homebrew cask:

```bash
brew cask doctor
brew cask install java android-sdk
brew cask install the-unarchiver mplayerx qlmarkdown android-file-transfer
brew cask install libreoffice skype electrum virtualbox cyberduck
```

## Todo

- Migrate from submodule to [subrepo](https://github.com/ingydotnet/git-subrepo)
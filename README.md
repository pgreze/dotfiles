# dotfiles

Yet Another Dotfiles project.

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
brew cask install the-unarchiver mplayerx qlmarkdown google-backup-and-sync android-file-transfer
brew cask install java android-sdk android-studio
brew cask install libreoffice skype electrum virtualbox cyberduck
```

## Todo

- Auto update mechanism like oh-my-zsh [check-for-upgrade](https://github.com/robbyrussell/oh-my-zsh/blob/master/tools/check_for_upgrade.sh) and [upgrade](https://github.com/robbyrussell/oh-my-zsh/blob/master/tools/upgrade.sh) combo.
- Migrate from submodule to [subrepo](https://github.com/ingydotnet/git-subrepo)

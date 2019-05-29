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
brew install python3 latex2rtf mkvtoolnix irssi ffmpeg
brew install git git-flow git-subrepo gcc cmake gdub
```

Homebrew cask:

```bash
brew cask doctor
brew cask install the-unarchiver mplayerx qlmarkdown google-backup-and-sync keepassxc flux
brew cask install iterm2 visual-studio-code java android-sdk android-studio
sudo pip3 install adb-enhanced # https://github.com/ashishb/adb-enhanced
brew cask install android-file-transfer libreoffice skype electrum virtualbox cyberduck
```

## SSH keys

After enabling *remote login* in *Sharing* preferences,
enable cross auto-login between old and new PCs:

```bash
# On previous PC
ssh user@new_pc mkdir .ssh
scp ~/.ssh/config ~/.ssh/id_rsa* user@new_pc:.ssh
ssh-copy-id -i ~/.ssh/id_rsa.pub user@new_pc
# On new PC
ssh-copy-id -i ~/.ssh/id_rsa.pub user@old_pc
```

## Todo

- Auto update mechanism like oh-my-zsh [check-for-upgrade](https://github.com/robbyrussell/oh-my-zsh/blob/master/tools/check_for_upgrade.sh) and [upgrade](https://github.com/robbyrussell/oh-my-zsh/blob/master/tools/upgrade.sh) combo.
- Migrate from submodule to [subrepo](https://github.com/ingydotnet/git-subrepo)
- use https://github.com/Peltoche/lsd

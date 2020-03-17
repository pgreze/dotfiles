# dotfiles

Yet Another Dotfiles project.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/pgreze/dotfiles/master/install.sh | sh
```

Homebrew:

```bash
brew doctor
brew install coreutils findutils wget rename tree ncdu htop autojump tmux thefuck
brew install python3 latex2rtf mkvtoolnix irssi ffmpeg
brew install git git-flow gcc cmake
```

Homebrew cask:

```bash
brew cask doctor
brew cask install the-unarchiver mplayerx qlmarkdown google-backup-and-sync keepassxc flux
brew cask install iterm2 visual-studio-code java android-sdk android-studio
sudo pip3 install adb-enhanced # https://github.com/ashishb/adb-enhanced
brew cask install android-file-transfer libreoffice skype electrum virtualbox cyberduck
```

Others:

```
# To expose ftp server with:
# python3 -m pyftpdlib
pip3 install pyftpdlib
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

## References

- [the-art-of-command-line](https://github.com/jlevy/the-art-of-command-line) for all shiny tools.

## (OSX) Change screenshots location

Before:
```
defaults write com.apple.screencapture location "/Users/pgreze/Drive/Screenshots/"
killall SystemUIServer
```

Now press Command+Shift+5 and change it in screenshot app:
![](https://www.howtogeek.com/wp-content/uploads/2019/01/img_5c521fdaac323.jpg.pagespeed.ce.WG_Ijkk6kr.jpg)

## Todo

- Auto update mechanism like oh-my-zsh [check-for-upgrade](https://github.com/robbyrussell/oh-my-zsh/blob/master/tools/check_for_upgrade.sh) and [upgrade](https://github.com/robbyrussell/oh-my-zsh/blob/master/tools/upgrade.sh) combo.
- Migrate from submodule to [subrepo](https://github.com/ingydotnet/git-subrepo)
- use https://github.com/Peltoche/lsd

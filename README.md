# dotfiles

Yet Another Dotfiles project.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/pgreze/dotfiles/master/install.sh | sh
```

Homebrew:

```bash
brew doctor
brew install coreutils bash grep findutils wget rename tree ncdu htop autojump tmux thefuck
brew install python3 latex2rtf mkvtoolnix irssi ffmpeg
brew install git git-subrepo git-flow gcc cmake
brew install exa procs bat ripgrep bat ripgrep dust bandwhich miniserve
# Python2 https://stackoverflow.com/a/60345962/5489877
brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/86a44a0a552c673a05f11018459c9f5faae3becc/Formula/python@2.rb
# TODO: kibi fdfind ytop licensor
brew install mas # https://github.com/mas-cli/mas 📦 Mac App Store command line interface
```

Homebrew cask:

```bash
brew cask doctor
brew cask install the-unarchiver vlc qlmarkdown google-backup-and-sync keepassxc flux
brew cask install iterm2 visual-studio-code
brew cask install java intellij-idea-ce android-sdk android-studio jd-gui
brew cask install android-file-transfer libreoffice skype electrum virtualbox cyberduck
# https://github.com/AdoptOpenJDK/homebrew-openjdk
brew tap AdoptOpenJDK/openjdk
brew cask install adoptopenjdk8 adoptopenjdk11
```

Others:

```
pip3 install pyftpdlib    # python3 -m pyftpdlib (expose ftp server)
pip3 install adb-enhanced # https://github.com/ashishb/adb-enhanced
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
- ![[twitter](https://twitter.com/jesusprubio/status/1237752138069094400/photo/1)](https://user-images.githubusercontent.com/14812354/77229554-236ef580-6bd2-11ea-8293-8c611a64a507.png) featuring:
  - https://github.com/ogham/exa
  - https://github.com/dalance/procs
  - https://github.com/sharkdp/bat
  - https://github.com/BurntSushi/ripgrep
  - https://github.com/ilai-deutel/kibi
  - https://github.com/sharkdp/fd
  - https://github.com/bootandy/dust
  - https://github.com/sharkdp/hyperfine
  - https://github.com/cjbassi/ytop
  - https://github.com/imsnif/bandwhich
  - https://github.com/svenstaro/miniserve
  - https://github.com/raftario/licensor

## (OSX) Change screenshots location

Before:
```
defaults write com.apple.screencapture location "/Users/pgreze/Drive/Screenshots/"
killall SystemUIServer
```

Now press Command+Shift+5 and change it in screenshot app:
![](https://www.howtogeek.com/wp-content/uploads/2019/01/img_5c521fdaac323.jpg.pagespeed.ce.WG_Ijkk6kr.jpg)

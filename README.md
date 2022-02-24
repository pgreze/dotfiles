# dotfiles

Yet Another Dotfiles project.

## Installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Homebrew:

```bash
brew doctor
brew install coreutils bash grep findutils curl wget gzip tree ncdu htop autojump tmux thefuck
brew install python3 latex2rtf mkvtoolnix irssi ffmpeg
brew install git git-subrepo git-flow gcc cmake
brew install git-delta exa procs bat ripgrep dust bandwhich miniserve

# Python2 https://stackoverflow.com/a/60345962/5489877
wget https://raw.githubusercontent.com/Homebrew/homebrew-core/86a44a0a552c673a05f11018459c9f5faae3becc/Formula/python@2.rb
brew install python@2.rb && rm python@2.rb
## Alternative with pyenv:
brew install pyenv && pyenv install 2.7.18

# TODO: kibi fdfind ytop licensor
brew install mas # https://github.com/mas-cli/mas 📦 Mac App Store command line interface
brew install robotsandpencils/made/xcodes # Allowing to install/manage several XCode versions.
```

Homebrew cask:

```bash
brew install --cask the-unarchiver vlc qlmarkdown google-drive keepassxc flux
brew install --cask iterm2 visual-studio-code
# https://github.com/AdoptOpenJDK/homebrew-openjdk
brew tap AdoptOpenJDK/openjdk && brew install --cask adoptopenjdk8 adoptopenjdk11
brew install --cask android-sdk jetbrains-toolbox jd-gui # intellij-idea-ce android-studio
brew install --cask transmission firefox virtualbox android-file-transfer libreoffice skype electrum cyberduck
brew install --cask docker docker-machine # ??
brew install --cask raspberry-pi-imager
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
  
## (OSX) How to Enable Key Repeating

See [this article for details](https://www.howtogeek.com/267463/how-to-enable-key-repeating-in-macos/):
```
defaults write -g ApplePressAndHoldEnabled -bool false
```

## (OSX) Change screenshots location

Before:
```
defaults write com.apple.screencapture location "/Users/pgreze/Drive/Screenshots/"
killall SystemUIServer
```

Now press Command+Shift+5 and change it in screenshot app:
![](https://www.howtogeek.com/wp-content/uploads/2019/01/img_5c521fdaac323.jpg.pagespeed.ce.WG_Ijkk6kr.jpg)

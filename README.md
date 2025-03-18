# dotfiles

Yet Another Dotfiles project.


## Installation

```bash
mkdir -p ~/git/pgreze
git clone --recursive git@github.com:pgreze/dotfiles.git ~/git/pgreze/dotfiles
~/git/pgreze/dotfiles/install.sh
```


### OSX 🍏

Homebrew:
```bash
# https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew doctor

# Essentials
brew install coreutils bash grep findutils curl wget gzip tree ncdu htop autojump tmux
brew install python3 latex2rtf mkvtoolnix irssi ffmpeg gcc cmake kubectx
brew install git gh git-flow git-delta # git-subrepo
brew install exa procs bat ripgrep dust bandwhich miniserve pipx

# Python2 https://stackoverflow.com/a/60345962/5489877
wget https://raw.githubusercontent.com/Homebrew/homebrew-core/86a44a0a552c673a05f11018459c9f5faae3becc/Formula/python@2.rb
brew install python@2.rb && rm python@2.rb
## Alternative with pyenv:
brew install pyenv && pyenv install 2.7.18

# TODO: kibi fdfind ytop licensor
brew install mas        # https://github.com/mas-cli/mas 📦 Mac App Store command line interface
mas install 539883307   # LINE
mas install 747648890   # Telegram
brew install robotsandpencils/made/xcodes # Allowing to install/manage several XCode versions.
```

Homebrew cask:
```bash
# Notice: lunar is not working well with my LG ultrawide
brew install --cask shifty keepassxc google-drive the-unarchiver qlmarkdown
brew install --cask obsidian rectangle bartender nordvpn
brew install --cask iterm2 visual-studio-code trailer sloth
# TODO: telegram
brew install --cask android-sdk jetbrains-toolbox jd-gui visualvm # intellij-idea-ce android-studio
brew install --cask transmission slack discord vlc firefox virtualbox android-file-transfer libreoffice skype electrum cyberduck
brew install --cask docker docker-machine
brew install --cask raspberry-pi-imager
```

https://endoflife.date/java
```bash
# Recommended way
curl -s "https://get.sdkman.io" | bash
for i in gradle kotlin kscript; do sdk install $i;done
sdk list java | grep -E '(tem|zulu)' | grep -E '(8|11|17)'
sdk install java $version

# With homebrew
brew tap homebrew/cask-versions && brew install --cask temurin8 temurin11
```

Others:
```bash
pip3 install pyftpdlib    # python3 -m pyftpdlib (expose ftp server)
pip3 install adb-enhanced # https://github.com/ashishb/adb-enhanced
```


### Linux 🐧

```bash
sudo apt install -y bat exa autojump tree
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

## OSX Tips

### Stop display this annoying terminal when pressing Cmd+Shift+A

[Manual operation](https://intellij-support.jetbrains.com/hc/en-us/articles/360005137400-Cmd-Shift-A-hotkey-opens-Terminal-with-apropos-search-instead-of-the-Find-Action-dialog)
or [script based](https://gist.github.com/mrmanc/72eb1712472242e8962661f59ea60ca8)

### How to Enable Key Repeating

See [this article for details](https://www.howtogeek.com/267463/how-to-enable-key-repeating-in-macos/):
```
defaults write -g ApplePressAndHoldEnabled -bool false
```


### Change screenshots location

Before:
```
defaults write com.apple.screencapture location "/Users/pgreze/Drive/Screenshots/"
killall SystemUIServer
```

Now press Command+Shift+5 and change it in screenshot app:
![](https://www.howtogeek.com/wp-content/uploads/2019/01/img_5c521fdaac323.jpg.pagespeed.ce.WG_Ijkk6kr.jpg)

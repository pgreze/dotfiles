###
### Declare or update environment variables.
###

# Editor
export EDITOR="/usr/bin/vim"
command_exists code && export EDITOR=code

# Add internal bin folder
export PATH="$HOME/.my/bin:$PATH"

# Export python startup script
export PYTHONSTARTUP=~/.pythonrc

# Android with homebrew
export ANDROID_HOME=/usr/local/opt/android-sdk
export ANDROID_SDK=$ANDROID_HOME
export ANDROID_NDK=/usr/local/opt/android-sdk/ndk-bundle/

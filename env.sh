###
### Declare or update environment variables.
###

# Editor
export EDITOR="/usr/bin/vim"
# Warning: if Visual studio code is not from homebrew and PATH injected in local.sh,
# This test will probably be wrong at this time
command_exists code && export EDITOR=code

# Add internal bin folder
export PATH="$HOME/.my/bin:$PATH"

# Export python startup script
export PYTHONSTARTUP=~/.pythonrc

# Android with homebrew
export ANDROID_HOME=/usr/local/opt/android-sdk
export ANDROID_SDK=$ANDROID_HOME
export ANDROID_NDK=$ANDROID_HOME/ndk-bundle/

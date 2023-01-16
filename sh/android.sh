###
### Android configuration
###
# brew install --cask android-commandlinetools
# https://github.com/Homebrew/homebrew-cask/pull/104687
#export PATH="$PATH:/opt/homebrew/share/android-commandlinetools/cmdline-tools/homebrew/bin/"

function setup_android_home {
    if [ -z $ANDROID_HOME ] && [ -d "$1" ]; then
        export ANDROID_HOME="$1"
        export ANDROID_SDK="$ANDROID_HOME"
        export ANDROID_NDK="$ANDROID_HOME/ndk-bundle/"
    fi
}
setup_android_home "$HOME/Library/Android/sdk"    # Android Studio location
setup_android_home "/usr/local/share/android-sdk" # Homebrew cask
setup_android_home "/usr/local/opt/android-sdk"   # 🤷

if [ ! -z $ANDROID_HOME ]; then
    export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"
fi

###
### Alias and functions
###

alias adb_restart='adb kill-server && sudo adb devices'

# Solving "Daemon could not be reused"
# https://twitter.com/chrisbanes/status/1244613598284054528
function android_set_jdk {
    if [ -z "$1" ]; then
        echo "Usage: $0 [android-sdk]. Available locations:"
        aidea.py
        return 0
    fi
    local android_studio="$1"
    export JAVA_HOME="$android_studio/Contents/jre/jdk/Contents/Home"
}

function icons_android {
    local dim="$1"
    local icon="$2"
    local target="$3"

    if [ -f "$icon" ] && [ -d "$target" ]; then
        cp "$icon" "cp-$icon" && sips -Z "${dim}x${dim}" "cp-$icon" > /dev/null && mv "cp-$icon" "$target/drawable-mdpi/$icon"
        cp "$icon" "cp-$icon" && sips -Z "$(echo $dim\*1.5/1 | bc)x$(echo $dim\*1.5/1 | bc)" "cp-$icon" > /dev/null && mv "cp-$icon" "$target/drawable-hdpi/$icon"
        cp "$icon" "cp-$icon" && sips -Z "$(echo $dim\*2/1 | bc)x$(echo $dim\*2/1 | bc)" "cp-$icon" > /dev/null && mv "cp-$icon" "$target/drawable-xhdpi/$icon"
        cp "$icon" "cp-$icon" && sips -Z "$(echo $dim\*3/1 | bc)x$(echo $dim\*3/1 | bc)" "cp-$icon" > /dev/null && mv "cp-$icon" "$target/drawable-xxhdpi/$icon"
    else
        echo 'Usage: icons8 32 ic_machin.png app/src/main/res'
        echo 'Description: downscale an icon (32dp here) into res/{m,h,xh,xxh}dpi folders'
        echo 'Please provide at least a dim*3 asset'
    fi
}

function android_take_picture {
    if [ -z $1 ];then
        echo "Missing destination path" >&2
        return
    fi
    if [ $(adb devices | grep device | wc -l) -lt 1 ];then
        echo "Device not found" >&2
        return
    fi
    adb shell /system/bin/screencap -p /sdcard/screenshot.png
    adb pull /sdcard/screenshot.png "$1"
    adb shell "rm /sdcard/screenshot.png"
}

alias adb_install_work='adb -d install --user $(adb -d shell pm list users | grep Work | grep -oE "[0-9]+" | head -n 1)'
alias adb_deeplink='adb shell am start -d'

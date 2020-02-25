###
### Android configuration
###

# Android with homebrew
if [ -z $ANDROID_HOME ] && [ -d /usr/local/opt/android-sdk ]; then
    export ANDROID_HOME=/usr/local/opt/android-sdk
    export ANDROID_SDK=$ANDROID_HOME
    export ANDROID_NDK=$ANDROID_HOME/ndk-bundle/
fi

alias adb_restart='adb kill-server && sudo adb devices'
# Start monitor (hierarchyviewer, etc) and restart adb at the end (monitor issue?)
alias monitor='/usr/local/bin/monitor; adb_restart'

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
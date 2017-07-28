###
### Contains common functions / aliases
### used with command line or in scripts.
### Content from ./env.sh was loaded at this point.
###

##
## General
##

function ping_with_date {
    local addr='8.8.8.8'
    if [ ! -z $@ ];then addr="$@";fi
    ping $addr | while read x;do echo "$(date +"%H:%M:%S"): $x";done
}

function extract {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1        ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1       ;;
            *.rar)       rar x $1     ;;
            *.gz)        gunzip $1     ;;
            *.tar)       tar xf $1        ;;
            *.tbz2)      tar xjf $1      ;;
            *.tgz)       tar xzf $1       ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1    ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

##
## Git
##

GIT_DEVELOP="develop"

alias gs='git st'
alias gd='git diff'

function spull {
    # Please be careful because we're:
    # - updating submodule urls (if changed)
    # - clean all previous work (with update -f).
    branch=$(git symbolic-ref --short HEAD)

    gco $GIT_DEVELOP && gl &&
        git submodule sync --recursive &&
        git submodule update --init --recursive -f

    # Go back to previous branch
    [[ $branch != $GIT_DEVELOP ]] && git co $branch
}

# Python
alias cleanpyc="find . -name '*.pyc' -delete"

##
## Android
##

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

##
## OSX
##

function osx_notification {
    # See https://goo.gl/cEE8Tc
    osascript -e "display notification \"$*\" with title \"Script alert\" sound name \"Glass.aiff\""
}

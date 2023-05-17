###
### General functions, when scope is unclear.
###

mkcd() {
  if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    mkdir --help
  else
    mkdir -v $*
    cd "${@: -1}"
  fi
}
alias cdmk=mkcd
alias cdd=mkcd

pong() {
  local addr='8.8.8.8'
  if [ ! -z $@ ]; then addr="$@"; fi
  ping $addr | while read x; do echo "$(date +"%H:%M:%S"): $x"; done
}

ffconvert() {
  local USAGE="Usage: $0 [file] [format]"
  [ "$1" = -h ] && echo $USAGE && return 0
  [ $# != 2 ] && echo $USAGE && return 1
  if [ ! -f $1 ]; then
    echo "'$1' is not a valid file"
    return 1
  fi
  local target="${1%.*}.$2"
  echo ">> Convert $1 --> $target"
  ffmpeg "$1" "$target"
}

extract() {
  if [ -f $1 ]; then
    case $1 in
    *.tar.bz2) tar xjf $1 ;;
    *.tar.gz) tar xzf $1 ;;
    *.bz2) bunzip2 $1 ;;
    *.rar) rar x $1 ;;
    *.gz) gunzip $1 ;;
    *.tar) tar xf $1 ;;
    *.tbz2) tar xjf $1 ;;
    *.tgz) tar xzf $1 ;;
    *.zip) unzip $1 ;;
    *.Z) uncompress $1 ;;
    *.7z) 7z x $1 ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
    return 1
  fi
}

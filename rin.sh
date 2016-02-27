##
## Rin is a 2012 macbook pro
##

echo "Rin configuration ..."

## Global mac configuration
source $HOME/.my/_osx.sh

## ALIAS

alias nvlc='/Applications/VLC.app/Contents/MacOS/VLC -I "curses" --browse-dir=~/Music'
alias emacs='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'

## PATH

# homebrew
export ANDROID_HOME=/usr/local/opt/android-sdk
export ANDROID_NDK=/usr/local/opt/android-ndk
export PATH="/usr/local/bin:/usr/local/share/npm/bin:/usr/local/sbin:$PATH"
export GROOVY_HOME=/usr/local/opt/groovy/libexec

# GHC cabal packages path
export PATH=$HOME/Library/Haskell/bin:$PATH

# rvm (from http://portertech.ca/2010/03/26/homebrew--rvm--awesome/)
source_if_exists $HOME/.rvm/scripts/rvm


##
## functions
##


function synchronise_itunes_music {
	# attention: bien mettre le / a la fin pour que Music soit pas recree dans OUTPUT
	INPUT="$HOME/Music/iTunes/iTunes Media/Music/"
	# le / a la fin est optionnel dans OUTPUT 
	OUTPUT="/Volumes/music/Music"

	if [ -d "$INPUT" ]; then
		if [ -d "$OUTPUT" ]; then
			echo "synchronise $INPUT => $OUTPUT"
			time rsync -rltgoDv --del --ignore-errors --exclude='*.DS_Store' --force "$INPUT" "$OUTPUT"
		else
			echo "Invalid OUTPUT $OUTPUT"
		fi
	else
		echo "Invalid INPUT $INPUT"
	fi
}

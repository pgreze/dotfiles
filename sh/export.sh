###
### Export configuration
###
# To add a new folder, add a case to the switch in the main loop below.
# All work happens in a subshell so functions and local vars never leak
# into the caller's shell. Set DOTFILES to override ~/.my.
(
    # Unique prefix for backup filenames in /tmp. Set once, used by all
    # handlers below (and inside recursive_symlink) via direct reference.
    prefix=$(date +%s)
    dotfiles="${DOTFILES:-$HOME/.my}"
    cd "$dotfiles" || { echo "Cannot cd to $dotfiles" >&2; exit 1; }

    # Symlink $src (path relative to dotfiles/) as $target.
    # Back up any existing target to /tmp first.
    symlink() {
        local src="$PWD/$1" target="$2"
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
            [ "${EXPORT_VERBOSE:-0}" = "1" ] && echo "Already linked: $target"
            return
        fi
        if [ -e "$target" ] || [ -L "$target" ]; then
            local backup="/tmp/${prefix}-${target##*/}"
            echo "Moving $target to $backup"
            mv "$target" "$backup"
        fi
        echo "$src -> $target"
        ln -s "$src" "$target"
    }

    # Symlink each file in $src into $target (creating $target if needed).
    # Use for things like export/herdr -> ~/.config/herdr so only listed
    # files are tracked; other files at the target are left alone.
    recursive_symlink() {
        local src="$1" target="$2"
        [ -d "$target" ] || mkdir -p "$target"
        for f in "$src"/*; do
            [ -f "$f" ] || continue  # only top-level files
            symlink "$f" "$target/${f##*/}"
        done
    }

    for item in export/*; do
        name="${item##*/}"

        # Files: symlink as ~/.<name>
        if [ -f "$item" ]; then
            symlink "$item" "$HOME/.$name"
            continue
        fi

        # Folders only from here on
        [ -d "$item" ] || continue

        case "$name" in
            edamame) recursive_symlink "$item/themes" "$HOME/.config/$name/themes" ;;
            ghostty) recursive_symlink "$item" "$HOME/.config/$name" ;;
            herdr)   recursive_symlink "$item" "$HOME/.config/$name" ;;
            helix)   recursive_symlink "$item" "$HOME/.config/$name" ;;
            *)       echo >&2 "ERROR: export/$name is missing a config" ;;
        esac
    done
)

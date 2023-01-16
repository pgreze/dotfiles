###
### Starship configuration.
### See https://starship.rs/config/ for customization.
###

function init_starship {
  # Install if not loaded + missing in path
  if [ -z "$STARSHIP_SHELL" ] && ! command -v starship > /dev/null; then
    echo ">> Install starship"
    case "$OSTYPE" in
      darwin*) brew install starship ;;
      *)       curl -sS https://starship.rs/install.sh | sh ;;
    esac
  fi

  generate_starship_config
}

function generate_starship_config {
  local config_file="$HOME/.config/starship.toml"
  mkdir -p "$HOME/.config"
  # Common
  cat > $config_file <<EOF
add_newline = true

[git_branch]
symbol = ""

[java]
style="bold red"

[git_commit]
disabled = true
[git_state]
disabled = true
[git_status]
disabled = true
EOF
  # OS specific
  case "$OSTYPE" in
    darwin*) cat >> $config_file <<EOF
[character]
success_symbol = "🍏 ➜ "
error_symbol = "🍎 ➜ "
EOF
    ;;
    linux*) cat >> $config_file <<EOF
[character]
success_symbol = "🐧 ➜ "
error_symbol = "🧨 ➜ "
EOF
    ;;
  esac
}

# https://starship.rs/guide/#getting-started
case $SHELL in
  */zsh)  init_starship && eval "$(starship init zsh)" ;;
  */bash) init_starship && eval "$(starship init bash)" ;;
  *)      echo "Unsupported shell, cannot load starship."
esac

unset -f init_starship
unset -f generate_starship_config

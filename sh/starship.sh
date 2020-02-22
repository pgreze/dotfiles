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
      *)       curl -fsSL https://starship.rs/install.sh | bash ;;
    esac
  fi

  generate_starship_config
}

function generate_starship_config {
  local config_file="$HOME/.config/starship.toml"
  mkdir -p "$HOME/.config"
  # OS specific
  case "$OSTYPE" in
    darwin*) cat > $config_file <<EOF
[character]
symbol = "🍏 ➜ "
error_symbol = "🍎 ➜ "
use_symbol_for_status = true
EOF
    ;;
    linux*) cat > $config_file <<EOF
[character]
symbol = "🐧 ➜ "
error_symbol = "🧨 ➜ "
use_symbol_for_status = true
EOF
    ;;
  esac
  # Common
  cat > $config_file <<EOF

[git_branch]
symbol = ""
EOF
}

# https://starship.rs/guide/#getting-started
case $SHELL in
  */zsh)  init_starship && eval "$(starship init zsh)" ;;
  */bash) init_starship && eval "$(starship init bash)" ;;
  *)      echo "Unsupported shell, cannot load starship."
esac

unset -f init_starship
unset -f generate_starship_config

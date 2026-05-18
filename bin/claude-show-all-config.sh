#!/usr/bin/env bash
# Show all user-facing Claude Code configuration in ~/.claude

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
VERBOSE=false

while getopts "vh" opt; do
  case $opt in
    v) VERBOSE=true ;;
    h)
      echo "Usage: $(basename "$0") [-v]"
      echo "  -v  Show file contents (piped through pager)"
      exit 0
      ;;
    *) exit 1 ;;
  esac
done

_main() {

# --- Colors ---
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
RESET='\033[0m'

header() { printf "\n${BOLD}${CYAN}=== %s ===${RESET}\n" "$1"; }
subheader() { printf "  ${DIM}%s${RESET}\n" "$1"; }
found() { printf "  ${GREEN}✓${RESET} %s\n" "$1"; }
missing() { printf "  ${DIM}✗ %s${RESET}\n" "$1"; }

show_file() {
  local file=$1
  local label=${2:-$file}
  if [[ -f "$file" ]]; then
    found "$label"
    if $VERBOSE; then
      printf "${DIM}"
      sed 's/^/    /' "$file"
      printf "${RESET}\n"
    fi
  else
    missing "$label (not found)"
  fi
}

show_symlink() {
  local link=$1
  local label=$(basename "$link")
  if [[ -L "$link" ]]; then
    local target
    target=$(readlink "$link")
    found "$label -> $target"
  elif [[ -e "$link" ]]; then
    found "$label"
  fi
}

# ==============================
# Global configuration
# ==============================

header "Global CLAUDE.md"
show_file "$CLAUDE_DIR/CLAUDE.md"

header "Global Settings"
show_file "$CLAUDE_DIR/settings.json"
show_file "$CLAUDE_DIR/settings.local.json"

header "Keybindings"
show_file "$CLAUDE_DIR/keybindings.json"

header "Scheduled Tasks"
show_file "$CLAUDE_DIR/scheduled_tasks.json"

# ==============================
# Hooks
# ==============================

header "Hooks"
subheader "$CLAUDE_DIR/hooks/ (scripts registered via settings.json -> hooks)"
if [[ -d "$CLAUDE_DIR/hooks" ]]; then
  hook_count=0
  while IFS= read -r -d '' f; do
    show_symlink "$f"
    hook_count=$((hook_count + 1))
  done < <(find "$CLAUDE_DIR/hooks" -maxdepth 1 \( -type f -o -type l \) 2>/dev/null | sort | tr '\n' '\0')
  if [[ $hook_count -eq 0 ]]; then
    missing "No hook scripts"
  fi
else
  missing "$CLAUDE_DIR/hooks/ (not found)"
fi

# ==============================
# Skills
# ==============================

header "Global Skills"
subheader "$CLAUDE_DIR/skills/"
if [[ -d "$CLAUDE_DIR/skills" ]]; then
  skill_count=0
  while IFS= read -r -d '' f; do
    show_symlink "$f"
    skill_count=$((skill_count + 1))
  done < <(find "$CLAUDE_DIR/skills" -maxdepth 1 \( -type d -o -type l \) -not -path "$CLAUDE_DIR/skills" 2>/dev/null | sort | tr '\n' '\0')
  if [[ $skill_count -eq 0 ]]; then
    missing "No global skills"
  fi
else
  missing "$CLAUDE_DIR/skills/ (not found)"
fi

# ==============================
# Commands (slash commands)
# ==============================

header "Global Commands (slash commands)"
subheader "$CLAUDE_DIR/commands/"
if [[ -d "$CLAUDE_DIR/commands" ]]; then
  cmd_count=0
  while IFS= read -r -d '' f; do
    local_name=$(basename "$f" .md)
    # Extract trigger from first non-empty line (typically the YAML-ish description)
    trigger=$(head -20 "$f" | grep -i -m1 'INVOKE WHEN\|trigger\|description\|^#' | head -1 | sed 's/^#* *//' || true)
    if [[ -n "$trigger" ]]; then
      found "/$local_name — $trigger"
    else
      found "/$local_name"
    fi
    if $VERBOSE; then
      printf "${DIM}"
      sed 's/^/    /' "$f"
      printf "${RESET}\n"
    fi
    cmd_count=$((cmd_count + 1))
  done < <(find "$CLAUDE_DIR/commands" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort | tr '\n' '\0')
  if [[ $cmd_count -eq 0 ]]; then
    missing "No global commands"
  fi
else
  missing "$CLAUDE_DIR/commands/ (not found)"
fi

# ==============================
# Plugins
# ==============================

header "Plugins"
subheader "$CLAUDE_DIR/plugins/installed_plugins.json"
local_plugins="$CLAUDE_DIR/plugins/installed_plugins.json"
if [[ -f "$local_plugins" ]]; then
  plugin_names=$(grep -oE '"[^"]+@[^"]+"' "$local_plugins" | tr -d '"' | sort -u)
  if [[ -n "$plugin_names" ]]; then
    while IFS= read -r name; do
      found "$name"
    done <<< "$plugin_names"
  else
    missing "No plugins installed"
  fi
  if $VERBOSE; then
    printf "${DIM}"
    sed 's/^/    /' "$local_plugins"
    printf "${RESET}\n"
  fi
else
  missing "No plugins installed"
fi

# ==============================
# MCP servers (from settings)
# ==============================

header "MCP Servers"
claude_json="${HOME}/.claude.json"
subheader "$claude_json -> mcpServers"
if [[ -f "$claude_json" ]] && grep -q '"mcpServers"' "$claude_json" 2>/dev/null; then
  python3 -c "
import json, sys
with open(sys.argv[1]) as fh:
    d = json.load(fh)
servers = d.get('mcpServers', {})
verbose = '--verbose' in sys.argv
if not servers:
    sys.exit(1)
for name in sorted(servers):
    srv = servers[name]
    detail = ''
    if 'url' in srv:
        detail = srv['url']
    elif 'command' in srv:
        detail = srv['command']
        if 'args' in srv:
            detail += ' ' + ' '.join(str(a) for a in srv.get('args', [])[:3])
    if detail:
        print(f'  \033[32m✓\033[0m {name} — {detail}')
    else:
        print(f'  \033[32m✓\033[0m {name}')
    if verbose and srv:
        import textwrap
        for line in json.dumps(srv, indent=2).splitlines():
            print(f'    \033[2m{line}\033[0m')
" "$claude_json" $($VERBOSE && echo "--verbose") 2>/dev/null || missing "No MCP servers configured"
else
  missing "No MCP servers configured"
fi

# ==============================
# Projects
# ==============================

header "Projects"
subheader "$CLAUDE_DIR/projects/"
if [[ -d "$CLAUDE_DIR/projects" ]]; then
  for proj_dir in "$CLAUDE_DIR/projects"/*/; do
    [[ -d "$proj_dir" ]] || continue
    proj_name=$(basename "$proj_dir")

    has_claude=$([[ -f "$proj_dir/CLAUDE.md" ]] && echo "y" || echo "")
    has_settings=$([[ -f "$proj_dir/settings.json" ]] && echo "y" || echo "")
    has_settings_local=$([[ -f "$proj_dir/settings.local.json" ]] && echo "y" || echo "")

    memory_count=0
    if [[ -d "$proj_dir/memory" ]]; then
      memory_count=$(find "$proj_dir/memory" -maxdepth 1 -name '*.md' -not -name 'MEMORY.md' 2>/dev/null | wc -l | tr -d ' ')
    fi

    badges=""
    [[ -n "$has_claude" ]] && badges+=" claude.md"
    [[ -n "$has_settings" ]] && badges+=" settings"
    [[ -n "$has_settings_local" ]] && badges+=" settings.local"
    [[ $memory_count -gt 0 ]] && badges+=" memories:${memory_count}"

    if [[ -n "$badges" ]]; then
      printf "  ${GREEN}✓${RESET} ${BOLD}%s${RESET}${YELLOW}%s${RESET}\n" "$proj_name" "$badges"
    else
      printf "  ${DIM}· %s (no config)${RESET}\n" "$proj_name"
    fi

    if $VERBOSE; then
      [[ -n "$has_claude" ]] && show_file "$proj_dir/CLAUDE.md" "    CLAUDE.md"
      [[ -n "$has_settings" ]] && show_file "$proj_dir/settings.json" "    settings.json"
      [[ -n "$has_settings_local" ]] && show_file "$proj_dir/settings.local.json" "    settings.local.json"
      if [[ $memory_count -gt 0 ]]; then
        while IFS= read -r -d '' mem; do
          mem_name=$(basename "$mem")
          printf "    ${DIM}📝 %s${RESET}\n" "$mem_name"
          head -5 "$mem" | sed 's/^/      /'
          printf "\n"
        done < <(find "$proj_dir/memory" -maxdepth 1 -name '*.md' -not -name 'MEMORY.md' 2>/dev/null | sort | tr '\n' '\0')
      fi
    fi
  done
else
  missing "$CLAUDE_DIR/projects/ (not found)"
fi

if ! $VERBOSE; then
  printf "\n${DIM}📚 Use -v to show file contents${RESET}\n"
fi
echo ""
}

if $VERBOSE; then
  if [[ -n "${PAGER:-}" ]]; then
    _main 2>&1 | $PAGER
  else
    _main 2>&1 | less -R
  fi
else
  _main
fi

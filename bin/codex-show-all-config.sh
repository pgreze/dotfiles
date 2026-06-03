#!/usr/bin/env bash
# Show all user-facing Codex configuration in ~/.codex

set -euo pipefail

CODEX_DIR="${CODEX_HOME:-${HOME}/.codex}"
CONFIG_FILE="${CODEX_DIR}/config.toml"
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

show_skill() {
  local skill_dir=$1
  local name
  name=$(basename "$skill_dir")
  local skill_file="$skill_dir/SKILL.md"
  local desc=""

  if [[ -f "$skill_file" ]]; then
    desc=$(awk '
      /^description:[[:space:]]*\|/ { in_desc=1; next }
      /^description:[[:space:]]*/ {
        sub(/^description:[[:space:]]*/, "")
        print
        exit
      }
      in_desc && /^  / {
        sub(/^  /, "")
        if (length($0) > 0) {
          print
          exit
        }
      }
      in_desc && !/^  / { exit }
    ' "$skill_file")
  fi

  if [[ -n "$desc" ]]; then
    found "$name — $desc"
  else
    show_symlink "$skill_dir"
  fi

  if $VERBOSE && [[ -f "$skill_file" ]]; then
    printf "${DIM}"
    sed 's/^/    /' "$skill_file"
    printf "${RESET}\n"
  fi
}

toml_query() {
  local query=$1
  if [[ ! -f "$CONFIG_FILE" ]]; then
    return 1
  fi

  python3 - "$CONFIG_FILE" "$query" "$VERBOSE" <<'PY'
import json
import sys

path, query, verbose_raw = sys.argv[1:4]
verbose = verbose_raw == "true"

def split_section(raw):
    parts = []
    buf = []
    in_quote = False
    escape = False
    for ch in raw:
        if escape:
            buf.append(ch)
            escape = False
        elif ch == "\\" and in_quote:
            escape = True
        elif ch == '"':
            in_quote = not in_quote
        elif ch == "." and not in_quote:
            parts.append("".join(buf))
            buf = []
        else:
            buf.append(ch)
    parts.append("".join(buf))
    return parts

def parse_value(raw):
    raw = raw.strip()
    if raw.startswith('"') and raw.endswith('"'):
        return raw[1:-1]
    if raw in ("true", "false"):
        return raw == "true"
    if raw.startswith("[") and raw.endswith("]"):
        inner = raw[1:-1].strip()
        if not inner:
            return []
        values = []
        buf = []
        in_quote = False
        escape = False
        for ch in inner:
            if escape:
                buf.append(ch)
                escape = False
            elif ch == "\\" and in_quote:
                escape = True
            elif ch == '"':
                in_quote = not in_quote
            elif ch == "," and not in_quote:
                values.append(parse_value("".join(buf).strip()))
                buf = []
            else:
                buf.append(ch)
        values.append(parse_value("".join(buf).strip()))
        return values
    return raw

sections = {}
current = ()
with open(path) as fh:
    for raw_line in fh:
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("[") and line.endswith("]"):
            current = tuple(split_section(line[1:-1]))
            sections.setdefault(current, {})
            continue
        if "=" in line and current:
            key, value = line.split("=", 1)
            sections.setdefault(current, {})[key.strip()] = parse_value(value)

def child_sections(prefix):
    prefix = tuple(prefix)
    result = {}
    for parts, values in sections.items():
        if len(parts) == len(prefix) + 1 and parts[:len(prefix)] == prefix:
            result[parts[-1]] = values
    return result

def nested_sections(prefix):
    prefix = tuple(prefix)
    result = {}
    for parts, values in sections.items():
        if parts[:len(prefix)] == prefix:
            label = ".".join(parts[len(prefix):]) or ".".join(parts)
            result[label] = values
    return result

GREEN = "\033[32m"
DIM = "\033[2m"
RESET = "\033[0m"

def ok(text):
    print(f"  {GREEN}✓{RESET} {text}")

if query == "marketplaces":
    for name, marketplace in sorted(child_sections(("marketplaces",)).items()):
        source_type = marketplace.get("source_type", "")
        source = marketplace.get("source", "")
        last_updated = marketplace.get("last_updated", "")
        detail = " ".join(part for part in [source_type, source] if part)
        if last_updated:
            detail = f"{detail} (updated {last_updated})" if detail else f"updated {last_updated}"
        ok(f"{name} — {detail}" if detail else name)
        if verbose and marketplace:
            for line in json.dumps(marketplace, indent=2, default=str).splitlines():
                print(f"    {DIM}{line}{RESET}")

elif query == "plugins":
    for name, plugin in sorted(child_sections(("plugins",)).items()):
        status = "enabled" if plugin.get("enabled", False) else "disabled"
        ok(f"{name} — {status}")
        if verbose and plugin:
            for line in json.dumps(plugin, indent=2, default=str).splitlines():
                print(f"    {DIM}{line}{RESET}")

elif query == "mcp":
    for name, server in sorted(child_sections(("mcp_servers",)).items()):
        detail = ""
        if "url" in server:
            detail = server["url"]
        elif "command" in server:
            args = " ".join(str(arg) for arg in server.get("args", [])[:4])
            detail = f"{server['command']} {args}".strip()
        ok(f"{name} — {detail}" if detail else name)
        if verbose:
            nested = nested_sections(("mcp_servers", name))
            for line in json.dumps(nested, indent=2, default=str).splitlines():
                print(f"    {DIM}{line}{RESET}")

elif query == "projects":
    for path, project in sorted(child_sections(("projects",)).items()):
        trust = project.get("trust_level", "")
        print(f"{path}\t{trust}")

else:
    sys.exit(2)
PY
}

plugin_manifest_label() {
  local manifest=$1
  python3 - "$manifest" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path) as fh:
    data = json.load(fh)

name = data.get("name") or path
version = data.get("version")
display = data.get("interface", {}).get("displayName")
short = data.get("interface", {}).get("shortDescription") or data.get("description", "").splitlines()[0]

label = display or name
if version:
    label += f"@{version}"
if short:
    label += f" — {short}"
print(label)
PY
}

automation_label() {
  local file=$1
  python3 - "$file" <<'PY'
import sys

try:
    import tomllib
except ModuleNotFoundError:
    print(sys.argv[1])
    sys.exit(0)

with open(sys.argv[1], "rb") as fh:
    data = tomllib.load(fh)

name = data.get("name") or sys.argv[1]
status = data.get("status")
kind = data.get("kind")
parts = [part for part in [kind, status] if part]
print(f"{name} — {' '.join(parts)}" if parts else name)
PY
}

# ==============================
# Global configuration
# ==============================

header "Global AGENTS.md"
show_file "$CODEX_DIR/AGENTS.md"

header "Global Config"
show_file "$CONFIG_FILE"

header "Desktop State"
show_file "$CODEX_DIR/.codex-global-state.json"
show_file "$CODEX_DIR/version.json"
show_file "$CODEX_DIR/models_cache.json"
show_file "$CODEX_DIR/cloud-requirements-cache.json"
show_file "$CODEX_DIR/computer-use/config.json"

# ==============================
# Marketplaces and plugins
# ==============================

header "Marketplaces"
subheader "$CONFIG_FILE -> marketplaces"
if ! toml_query marketplaces 2>/dev/null; then
  missing "No marketplaces configured"
fi

header "Plugins"
subheader "$CONFIG_FILE -> plugins"
if ! toml_query plugins 2>/dev/null; then
  missing "No plugins configured"
fi

header "Cached Plugin Manifests"
subheader "$CODEX_DIR/plugins/cache/"
if [[ -d "$CODEX_DIR/plugins/cache" ]]; then
  plugin_count=0
  while IFS= read -r -d '' manifest; do
    found "$(plugin_manifest_label "$manifest")"
    if $VERBOSE; then
      printf "${DIM}"
      sed 's/^/    /' "$manifest"
      printf "${RESET}\n"
    fi
    plugin_count=$((plugin_count + 1))
  done < <(find "$CODEX_DIR/plugins/cache" -path '*/.codex-plugin/plugin.json' 2>/dev/null | sort | tr '\n' '\0')
  if [[ $plugin_count -eq 0 ]]; then
    missing "No cached plugin manifests"
  fi
else
  missing "$CODEX_DIR/plugins/cache/ (not found)"
fi

# ==============================
# Skills
# ==============================

header "Global Skills"
subheader "$CODEX_DIR/skills/"
if [[ -d "$CODEX_DIR/skills" ]]; then
  skill_count=0
  while IFS= read -r -d '' f; do
    show_skill "$f"
    skill_count=$((skill_count + 1))
  done < <(find "$CODEX_DIR/skills" -maxdepth 1 \( -type d -o -type l \) -not -path "$CODEX_DIR/skills" -not -name '.system' 2>/dev/null | sort | tr '\n' '\0')
  if [[ $skill_count -eq 0 ]]; then
    missing "No global skills"
  fi
else
  missing "$CODEX_DIR/skills/ (not found)"
fi

header "System Skills"
subheader "$CODEX_DIR/skills/.system/"
if [[ -d "$CODEX_DIR/skills/.system" ]]; then
  system_skill_count=0
  while IFS= read -r -d '' f; do
    show_skill "$f"
    system_skill_count=$((system_skill_count + 1))
  done < <(find "$CODEX_DIR/skills/.system" -maxdepth 1 \( -type d -o -type l \) -not -path "$CODEX_DIR/skills/.system" 2>/dev/null | sort | tr '\n' '\0')
  if [[ $system_skill_count -eq 0 ]]; then
    missing "No system skills"
  fi
else
  missing "$CODEX_DIR/skills/.system/ (not found)"
fi

# ==============================
# MCP servers
# ==============================

header "MCP Servers"
subheader "$CONFIG_FILE -> mcp_servers"
if ! toml_query mcp 2>/dev/null; then
  missing "No MCP servers configured"
fi

# ==============================
# Automations and memories
# ==============================

header "Automations"
subheader "$CODEX_DIR/automations/*/automation.toml"
if [[ -d "$CODEX_DIR/automations" ]]; then
  automation_count=0
  while IFS= read -r -d '' f; do
    found "$(automation_label "$f")"
    if $VERBOSE; then
      printf "${DIM}"
      sed 's/^/    /' "$f"
      printf "${RESET}\n"
    fi
    automation_count=$((automation_count + 1))
  done < <(find "$CODEX_DIR/automations" -maxdepth 2 -type f -name 'automation.toml' 2>/dev/null | sort | tr '\n' '\0')
  if [[ $automation_count -eq 0 ]]; then
    missing "No automations"
  fi
else
  missing "$CODEX_DIR/automations/ (not found)"
fi

header "Memories"
subheader "$CODEX_DIR/memories/"
if [[ -d "$CODEX_DIR/memories" ]]; then
  memory_count=0
  while IFS= read -r -d '' f; do
    show_symlink "$f"
    if $VERBOSE && [[ -f "$f" ]]; then
      printf "${DIM}"
      sed 's/^/    /' "$f"
      printf "${RESET}\n"
    fi
    memory_count=$((memory_count + 1))
  done < <(find "$CODEX_DIR/memories" -maxdepth 1 \( -type f -o -type l \) 2>/dev/null | sort | tr '\n' '\0')
  if [[ $memory_count -eq 0 ]]; then
    missing "No memories"
  fi
else
  missing "$CODEX_DIR/memories/ (not found)"
fi

# ==============================
# Projects
# ==============================

header "Projects"
subheader "$CONFIG_FILE -> projects"
project_count=0
if [[ -f "$CONFIG_FILE" ]]; then
  while IFS=$'\t' read -r proj_dir trust_level; do
    [[ -n "$proj_dir" ]] || continue
    badges=""
    [[ -n "$trust_level" ]] && badges+=" trust:${trust_level}"
    [[ -f "$proj_dir/AGENTS.md" ]] && badges+=" AGENTS.md"
    [[ -f "$proj_dir/.codex/config.toml" ]] && badges+=" .codex/config.toml"

    if [[ -n "$badges" ]]; then
      printf "  ${GREEN}✓${RESET} ${BOLD}%s${RESET}${YELLOW}%s${RESET}\n" "$proj_dir" "$badges"
    else
      printf "  ${DIM}· %s (no extra project config found)${RESET}\n" "$proj_dir"
    fi

    if $VERBOSE; then
      [[ -f "$proj_dir/AGENTS.md" ]] && show_file "$proj_dir/AGENTS.md" "    AGENTS.md"
      [[ -f "$proj_dir/.codex/config.toml" ]] && show_file "$proj_dir/.codex/config.toml" "    .codex/config.toml"
    fi

    project_count=$((project_count + 1))
  done < <(toml_query projects 2>/dev/null || true)
fi
if [[ $project_count -eq 0 ]]; then
  missing "No projects configured"
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

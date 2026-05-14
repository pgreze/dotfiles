###
### Claude Code configuration
###

# Install Claude Code hooks and skills from dotfiles if not already present.
# Source files live in $DOTFILES/export/claude/ and get symlinked to ~/.claude/.
_claude_install() {
    local src="$DOTFILES/export/claude"
    local dst="$HOME/.claude"

    [ -d "$src" ] || return 0
    mkdir -p "$dst/hooks" "$dst/skills"

    # Symlink hooks
    for hook in "$src"/hooks/*.sh; do
        [ -f "$hook" ] || continue
        local name="${hook##*/}"
        if [ ! -L "$dst/hooks/$name" ]; then
            ln -sf "$hook" "$dst/hooks/$name"
        fi
    done

    # Symlink skills (each skill is a directory)
    for skill_dir in "$src"/skills/*/; do
        [ -d "$skill_dir" ] || continue
        local name="${skill_dir%/}"
        name="${name##*/}"
        if [ ! -L "$dst/skills/$name" ]; then
            ln -sfn "$skill_dir" "$dst/skills/$name"
        fi
    done

    # Ensure settings.json has the PreToolUse hook for block-dangerous-commands
    local settings="$dst/settings.json"
    [ -f "$settings" ] || echo '{}' > "$settings"
    if ! grep -q "block-dangerous-commands" "$settings"; then
        local tmp
        tmp=$(mktemp)
        jq '.hooks.PreToolUse = ((.hooks.PreToolUse // []) + [{"matcher": "Bash", "hooks": [{"type": "command", "command": "~/.claude/hooks/block-dangerous-commands.sh"}]}])' "$settings" > "$tmp" && mv "$tmp" "$settings"
    fi
}
_claude_install

vsclaude() {
    local url="vscode://anthropic.claude-code/open"
    if [[ -n "$1" ]]; then
        url="${url}?prompt=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$*'))")"
    fi
    open "$url"
}

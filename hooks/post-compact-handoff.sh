#!/usr/bin/env bash
PROJ="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJ/.claude" 2>/dev/null||true
cat > "$PROJ/.claude/HANDOFF.md" << H
# Handoff — $(date +%Y%m%d_%H%M%S) (post-compact)
Branch: $(cd "$PROJ" && git branch --show-current 2>/dev/null || echo "?")
Modified: $(cd "$PROJ" && git diff --name-only 2>/dev/null | head -20)
Commits: $(cd "$PROJ" && git log --oneline -3 2>/dev/null || echo "none")
Resume: read this, check git diff, run tests, continue from TODO.
H
echo '{"hookSpecificOutput":{"hookEventName":"PostCompact","additionalContext":"Compacted. Read .claude/HANDOFF.md to restore context."}}'
exit 0

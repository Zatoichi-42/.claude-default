#!/usr/bin/env bash
INPUT=$(cat 2>/dev/null || echo '{}')
AN=$(echo "$INPUT" | jq -r '.agent_name // "unknown"' 2>/dev/null || echo "unknown")
PROJ="${CLAUDE_PROJECT_DIR:-.}"
[ "$AN" = "tdd-test-writer" ] && [ -n "$CLAUDE_ENV_FILE" ] && echo "export CLAUDE_TDD_PHASE=red" >> "$CLAUDE_ENV_FILE"
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStart\",\"additionalContext\":\"Project: $PROJ | Branch: $(cd "$PROJ" && git branch --show-current 2>/dev/null || echo unknown)\"}}"
exit 0

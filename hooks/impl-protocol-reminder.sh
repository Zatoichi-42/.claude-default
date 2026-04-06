#!/usr/bin/env bash
# Injects the Implementation Protocol reminder when the user submits an
# implementation-intent prompt. Fires on UserPromptSubmit.
INPUT=$(cat 2>/dev/null || echo '{}')
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || true)
[ -z "$PROMPT" ] && exit 0

# Match implementation-intent keywords (case-insensitive, word-boundary-ish)
if echo "$PROMPT" | grep -qiE '\b(build|implement|add|create|fix|write|stage|step)\b'; then
  MSG="IMPLEMENTATION PROTOCOL (no exceptions): (1) Read CLAUDE.md + .claude/agents/ + config/ + evals/ + docs/ first. (2) Follow the build sequence exactly — no skipping, no building ahead. (3) Run npm test after EACH step — do not proceed until green. (4) When stage complete: STOP, write summary, run /simplify, produce audit table (Item | Complete % | Reason | Suggestion), offer to implement suggestions. Use /build to invoke this protocol explicitly."
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":\"$MSG\"}}"
fi
exit 0

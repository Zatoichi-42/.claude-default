#!/usr/bin/env bash
# ============================================================================
# pre-tool-security.sh — Block dangerous Bash commands
# EXIT: 0 with JSON decision = block/allow. Exit 2 = hard block on crash.
# ============================================================================

trap 'echo "BLOCKED: Security hook crashed — failing closed" >&2; exit 2' ERR

INPUT=$(cat 2>/dev/null || echo '{}')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$COMMAND" ] && exit 0

# Block credential/secret commits
if echo "$COMMAND" | grep -qiE 'git (add|commit)'; then
  if git diff --cached --name-only 2>/dev/null | grep -qE '\.(env|key|pem|p12)$|secrets|credentials'; then
    echo '{"hookSpecificOutput":{"decision":"block","reason":"BLOCKED: Staging/committing sensitive files (.env, .key, .pem, credentials)"}}'
    exit 0
  fi
fi

# Block destructive operations
if echo "$COMMAND" | grep -qE 'rm -rf [^.]|drop (database|table)|truncate|:(){ :|:& };:'; then
  echo '{"hookSpecificOutput":{"decision":"block","reason":"BLOCKED: Destructive command detected"}}'
  exit 0
fi

# Block force-push to main
if echo "$COMMAND" | grep -qE 'git push.*(-f|--force).*(main|master)'; then
  echo '{"hookSpecificOutput":{"decision":"block","reason":"BLOCKED: Force push to main/master"}}'
  exit 0
fi

# Block writing secrets via Bash redirects
if echo "$COMMAND" | grep -qiE '(echo|printf|cat).*>.*\.(env|key|pem)'; then
  echo '{"hookSpecificOutput":{"decision":"block","reason":"BLOCKED: Writing to sensitive file via redirect"}}'
  exit 0
fi

exit 0

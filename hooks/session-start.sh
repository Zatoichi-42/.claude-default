#!/usr/bin/env bash
# ============================================================================
# session-start.sh — Load context, verify hooks, warn about issues
# ============================================================================

echo "=== Session Start ==="
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'not in git')"
echo "Modified: $(git diff --name-only 2>/dev/null | wc -l | tr -d ' ') files"

# Fix hook permissions (this WILL be needed after git clone)
for hook in .claude/hooks/*.sh; do
  if [ -f "$hook" ] && [ ! -x "$hook" ]; then
    chmod +x "$hook" 2>/dev/null && echo "Fixed permissions: $hook"
  fi
done

# Check jq (hooks depend on it)
if ! command -v jq &>/dev/null; then
  echo "WARNING: jq not installed. Security hooks will FAIL CLOSED."
  echo "Install: brew install jq / apt install jq / pip install jq"
fi

# Prune old logs (>7 days)
find .claude/logs/ -name "*.log" -mtime +7 -delete 2>/dev/null || true

# Load journal (context recovery)
if [ -f ".claude/JOURNAL.md" ]; then
  echo ""
  echo "=== Previous Session State ==="
  cat .claude/JOURNAL.md
  echo "=== End State ==="
fi

# Show blocked items if any
if [ -f ".claude/BLOCKED.md" ] && [ -s ".claude/BLOCKED.md" ]; then
  echo ""
  echo "=== BLOCKED ITEMS (need attention) ==="
  cat .claude/BLOCKED.md
  echo "=== End Blocked ==="
fi

# Ratchet state summary
if [ -f ".claude/ratchet-state.json" ] && command -v jq &>/dev/null; then
  echo "Ratchet: $(jq -r '"exp=" + (.experiment_count|tostring) + " kept=" + (.kept_improvements|length|tostring)' .claude/ratchet-state.json 2>/dev/null || echo 'unreadable')"
fi

# TODO status
REMAINING=0
DONE=0
for f in TODO.md .claude/TODO.md; do
  if [ -f "$f" ]; then
    REMAINING=$(grep -c '^\- \[ \]' "$f" 2>/dev/null || echo 0)
    DONE=$(grep -c '^\- \[x\]' "$f" 2>/dev/null || echo 0)
    break
  fi
done
echo "Tasks: $DONE done / $((DONE + REMAINING)) total ($REMAINING remaining)"

echo "====================="
exit 0

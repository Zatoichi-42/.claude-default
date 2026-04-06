#!/usr/bin/env bash
# ============================================================================
# stop-journal.sh — Write JOURNAL.md on every Claude turn
# Survives crashes, rate limits, session kills. At most 1 turn stale.
# CRITICAL: Must check stop_hook_active to prevent infinite loop.
# ============================================================================

INPUT=$(cat 2>/dev/null || echo '{}')

# INFINITE LOOP GUARD — if we're already in a stop hook cycle, exit silently
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")
[ "$STOP_ACTIVE" = "true" ] && exit 0

TS=$(date +%Y-%m-%d\ %H:%M:%S)
BR=$(git branch --show-current 2>/dev/null || echo "unknown")
MC=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
LC=$(git log --oneline -3 2>/dev/null || echo "none")

# Quick test status (30s timeout, non-blocking)
TEST="unknown"
if [ -f "pyproject.toml" ] || [ -f "pytest.ini" ] || [ -f "setup.py" ] || [ -f "setup.cfg" ]; then
  (timeout 30 python -m pytest --tb=no -q 2>/dev/null) && TEST="PASSING" || TEST="FAILING"
elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  (timeout 30 npm run test -- --passWithNoTests --silent 2>/dev/null) && TEST="PASSING" || TEST="FAILING"
fi

# Next tasks from TODO.md
TN="none"
for f in TODO.md .claude/TODO.md; do
  [ -f "$f" ] && { TN=$(grep -m3 '^\- \[ \]' "$f" 2>/dev/null || echo "none"); break; }
done

# Blocked items
BLOCKED=""
if [ -f ".claude/BLOCKED.md" ]; then
  BLOCKED=$(cat .claude/BLOCKED.md 2>/dev/null | head -10)
fi

mkdir -p .claude 2>/dev/null || true

cat > .claude/JOURNAL.md << JOURNAL
# Journal — ${TS}
Branch: ${BR} | ${MC} uncommitted | Tests: ${TEST}
Commits: ${LC}
Next: ${TN}
${BLOCKED:+Blocked items: ${BLOCKED}}
Resume: read this, check git diff, run tests, continue next incomplete task.
JOURNAL

cp .claude/JOURNAL.md .claude/HANDOFF.md 2>/dev/null || true

# Warn if tests failing (minimal output to avoid loop)
[ "$TEST" = "FAILING" ] && echo "Tests FAILING." >&2

exit 0

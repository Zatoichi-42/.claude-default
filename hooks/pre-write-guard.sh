#!/usr/bin/env bash
# ============================================================================
# pre-write-guard.sh — Protect locked files, allow TDD test writing
#
# CRITICAL FIX: The previous version blocked tdd-test-writer subagent from
# writing test files because it checked CLAUDE_TDD_PHASE env var, which
# subagents cannot inherit. Now we detect agent context from stdin JSON.
#
# EXIT CODES: exit 0 = allow, exit 2 = block
# (exit 1 is NON-BLOCKING in Claude Code — never use it to deny)
# ============================================================================

# Fail closed on any unexpected error
trap 'echo "BLOCKED: Write guard crashed — failing closed" >&2; exit 2' ERR

INPUT=$(cat 2>/dev/null || echo '{}')

# If we can't parse input, allow (non-write call)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

# --- Always protect lock files and generated code ---
if echo "$FILE_PATH" | grep -qE 'package-lock\.json|yarn\.lock|pnpm-lock\.yaml|poetry\.lock|\.gen\.|\.generated\.'; then
  echo '{"hookSpecificOutput":{"decision":"block","reason":"BLOCKED: Protected/generated file. Do not edit directly."}}'
  exit 0
fi

# --- Test file protection (THE FIX) ---
# Only block test-file edits during IMPLEMENTATION, not during test-writing.
# Detect context: if an agent named "tdd-test-writer" is running, allow writes.
# Also allow if the file doesn't match test patterns at all.
if echo "$FILE_PATH" | grep -qE '\.test\.|\.spec\.|test_|_test\.py|__tests__/|/test/|/tests/'; then
  # This IS a test file. Check if we're in a test-writing context.
  
  # Method 1: Check agent_name from the hook input JSON
  AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_name // empty' 2>/dev/null)
  if [ "$AGENT_NAME" = "tdd-test-writer" ]; then
    exit 0  # Test writers are explicitly allowed to write test files
  fi
  
  # Method 2: Check for TDD phase env var (belt-and-suspenders)
  if [ "${CLAUDE_TDD_PHASE:-}" = "red" ]; then
    exit 0
  fi

  # Method 3: Check for a marker file that the TDD skill creates
  if [ -f ".claude/.tdd-red-phase" ]; then
    exit 0
  fi
  
  # If none of the above: block test-file edits during implementation
  echo '{"hookSpecificOutput":{"decision":"block","reason":"BLOCKED: Cannot modify test files during implementation. Tests are the specification. Fix the source code instead. If you are writing NEW tests, use the tdd-test-writer agent or create .claude/.tdd-red-phase marker."}}'
  exit 0
fi

exit 0

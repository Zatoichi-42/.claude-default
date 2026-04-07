#!/usr/bin/env bash
# UserPromptSubmit hook — injects live Build Sequence from project CLAUDE.md.
# Hard-blocks when no sequence found. /quick [task] bypasses for one prompt.

INPUT=$(cat)

PROMPT=$(jq -r '.prompt // ""'  <<< "$INPUT" 2>/dev/null)
PROJECT_DIR=$(jq -r '.cwd // ""' <<< "$INPUT" 2>/dev/null)
[ -z "$PROJECT_DIR" ] && PROJECT_DIR="$PWD"

# /quick bypass — first line only to prevent mid-prompt triggers
FIRST_LINE="${PROMPT%%$'\n'*}"
if [[ "$FIRST_LINE" =~ ^[[:space:]]*/quick([[:space:]]|$) ]]; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"/quick bypass active — build sequence checks skipped for this prompt. No protocol enforcement."}}'
  exit 0
fi

find_claude_md() {
  local dir="$1"
  while [[ "$dir" != "/" && -n "$dir" ]]; do
    [[ -f "$dir/CLAUDE.md" ]] && { echo "$dir/CLAUDE.md"; return 0; }
    dir="${dir%/*}"
  done
  return 1
}

block() { jq -n --arg r "$1" '{"decision":"block","reason":$r}'; exit 0; }
emit()  { jq -n --arg c "$1" '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":$c}}'; exit 0; }

FORMAT_TEMPLATE='Add this to your CLAUDE.md:

## Build Sequence

> Claude: read this on every turn. Find the first unchecked - [ ] box. That is your current step.
> Do not proceed until ALL gates for the current phase are met.

### Phase 1 — [name]
- [ ] Step description
- [ ] Run the test command → GREEN
- [ ] Run /simplify on changed files

**Gate:** all boxes checked, tests passing.

## Test Command
your-test-command-here

Format rules:
  - [ ] = unchecked (do this next)
  - [x] = done (skip)
  **Gate:** = must be satisfied before advancing to next phase
  /quick [task] = bypass build sequence for one-off tasks'

CLAUDE_PATH=$(find_claude_md "$PROJECT_DIR")
[ -z "$CLAUDE_PATH" ] && block "BLOCKED: No CLAUDE.md found in project tree ($PROJECT_DIR). $FORMAT_TEMPLATE"

BUILD_SECTION=$(awk '/^## Build Sequence/{found=1; next} found && /^## /{exit} found{print}' "$CLAUDE_PATH")
[[ -z "${BUILD_SECTION//[[:space:]]/}" ]] && block "BLOCKED: ## Build Sequence in $CLAUDE_PATH is empty. $FORMAT_TEMPLATE"

if ! [[ "$BUILD_SECTION" == *"- [ ]"* ]]; then
  emit "All steps complete (no unchecked boxes in $CLAUDE_PATH). Add new steps or confirm the phase is done."
fi

emit "LIVE BUILD SEQUENCE from $CLAUDE_PATH (re-read fresh this prompt)

Format: - [ ] unchecked (do this next) | - [x] done (skip) | **Gate:** must be met before advancing | /quick [task] = bypass for one-off tasks

$BUILD_SECTION

---
INSTRUCTION: Find the first - [ ] box above. That is your ONLY current step. Do not skip. Do not build ahead. Run the test command after each step. When all phase boxes are checked: STOP — write summary, run /simplify, produce audit table (Item | Complete % | Reason | Suggestion), offer to implement."

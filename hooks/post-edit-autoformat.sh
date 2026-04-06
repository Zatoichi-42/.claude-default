#!/usr/bin/env bash
# ============================================================================
# post-edit-autoformat.sh — Auto-format after Claude edits a file
# PostToolUse hooks CANNOT block. Exit code doesn't matter for blocking.
# All operations are best-effort.
# ============================================================================

INPUT=$(cat 2>/dev/null || true)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)

[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in
  *.py)
    ruff format "$FILE_PATH" 2>/dev/null || black "$FILE_PATH" 2>/dev/null || true
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.html|*.md)
    npx prettier --write "$FILE_PATH" 2>/dev/null || true
    ;;
  *.go)
    gofmt -w "$FILE_PATH" 2>/dev/null || true
    ;;
esac

exit 0

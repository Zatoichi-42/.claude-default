#!/usr/bin/env bash
# ============================================================================
# notify.sh — Desktop notification when Claude needs attention
# Async, non-blocking. Best effort on all platforms.
# ============================================================================

TITLE="Claude Code"
MSG="Waiting for your input"

# macOS
if command -v osascript &>/dev/null; then
  osascript -e "display notification \"$MSG\" with title \"$TITLE\"" 2>/dev/null || true
# Linux (notify-send)
elif command -v notify-send &>/dev/null; then
  notify-send "$TITLE" "$MSG" 2>/dev/null || true
# Fallback: terminal bell
else
  printf '\a' 2>/dev/null || true
fi

exit 0

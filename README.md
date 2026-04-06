# ~/.claude-default

Golden-copy Claude Code configuration extracted from the Hydra project. Contains only what was proven useful at runtime — no unused commands, agents, or docs.

## What's Here

```
~/.claude-default/
├── CLAUDE.md                  # Global constitution: Implementation Protocol, TDD, Code Rules
├── settings.json              # Hooks + permissions (copy to ~/.claude/)
├── hooks/                     # 9 event-driven hooks
│   ├── session-start.sh       # SessionStart: loads journal, branch, ratchet state
│   ├── pre-tool-security.sh   # PreToolUse:Bash: blocks destructive ops, secret commits
│   ├── pre-write-guard.sh     # PreToolUse:Write: TDD phase guard on test files
│   ├── post-edit-autoformat.sh# PostToolUse:Write: auto-prettier/black/gofmt
│   ├── post-compact-handoff.sh# PostCompact: writes HANDOFF.md for session recovery
│   ├── stop-journal.sh        # Stop: writes JOURNAL.md with test status
│   ├── subagent-start.sh      # SubagentStart: sets TDD phase for test-writer
│   ├── impl-protocol-reminder.sh # UserPromptSubmit: injects build protocol on keywords
│   └── notify.sh              # Notification: desktop alert on idle
├── commands/
│   ├── build.md               # /build: staged implementation with audit table
│   ├── evolve.md              # /evolve: ratchet loop for agent prompts
│   └── status.md              # /status: project health summary
├── rules/
│   ├── safety.md              # Fires on: *.sh, *.env*, hooks/*, Dockerfile
│   ├── testing.md             # Fires on: *.test.*, *.spec.*, __tests__/
│   └── ui.md                  # Fires on: *.tsx, *.jsx, *.vue, *.svelte
├── agents/
│   └── TEMPLATE.md            # How to write agent specs
└── config/
    └── evolution-config.yaml  # Budget caps, circuit breaker, iteration limits
```

## How to Use

### New project — full setup

```bash
# Copy global config (do this once)
cp ~/.claude-default/CLAUDE.md ~/.claude/CLAUDE.md
cp ~/.claude-default/settings.json ~/.claude/settings.json
cp -r ~/.claude-default/hooks/ ~/.claude/hooks/
cp -r ~/.claude-default/rules/ ~/.claude/rules/
cp -r ~/.claude-default/commands/ ~/.claude/commands/

# Copy project-local templates
mkdir -p .claude/commands .claude/agents config
cp ~/.claude-default/agents/TEMPLATE.md .claude/agents/
cp ~/.claude-default/config/evolution-config.yaml config/
```

### Existing project — add missing pieces

Compare what you have with what's here and copy what's missing.

## What This Does NOT Include

Excluded because Hydra never used them:

- zibe-\* commands (16 commands — bootstrap, check, dashboard, etc.)
- Global agents (code-reviewer, self-critic, tdd-test-writer, tdd-implementer, ui-tester)
- Global docs (MANUAL.md, ARCHITECTURE.md, PATTERNS.md, etc.)
- Proof protocol (zibe-prove, zibe-sync-todo)
- Model/effort enforcement (zibe-model, zibe-effort, zibe-enforcement)

These exist in ~/.claude/ and may be useful for other workflows, but were not load-bearing for the Hydra project.

## Origin

Extracted 2026-04-06 from the Hydra project (agentic hedge fund OS).
Hydra proved: hooks → rules → Implementation Protocol → /build → /evolve → /simplify is a complete development loop.

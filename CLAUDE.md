# Claude Code — Global Constitution

## Prime Directives

1. Read this file, then project CLAUDE.md, then .claude/rules/ before substantive work.
2. Do not edit non-test source without a recent RED signal (failing test).
3. No silent failures — all code paths return data or typed errors.
4. Do not let unrelated failing tests redefine the current task.
5. There are no edge cases. If it can happen, it will. Every failure mode is a main path.

## Implementation Protocol (no exceptions)

Every implementation session — whether invoked via `/build` or a plain request — must follow this protocol:

1. Read this file, then project CLAUDE.md, then `.claude/agents/`, `config/`, `evals/`, `docs/` before touching any code.
2. Follow the project's build sequence exactly. Do not skip steps. Do not build ahead.
3. After **each step**, run the project's test command. Do not proceed until tests pass.
4. When a stage is complete: **stop**. Write a plain-English summary of what was built.
5. Run `/simplify` on all changed files.
6. Produce an audit table: Item | Complete % | Reason | Suggestion. Verify by reading code, not guessing.
7. Ask: "Would you like me to implement the suggestions?" If yes, implement them.

Use `/build` to invoke this protocol explicitly.

## TDD Protocol

1. Name the tests first — describe what you're proving before writing anything.
2. Write tests before implementation. Confirm RED.
3. Implement the MINIMUM to go GREEN. Refactor only while GREEN.
4. If the user gives an exact error string, reproduce it EXACTLY in a test.
5. Reproduce the exact user command before claiming a fix.
6. For CLI bugs, add integration tests for the real entrypoint.
7. NEVER modify test files to make them pass — fix the source code.

## Code Rules

- Files under 300 lines. Functions under 40 lines.
- No `any` types — use `unknown` and narrow.
- Surface errors to STDOUT. Return Result types or typed errors.
- Prefer composition over inheritance. Named exports over default.

## Context Management

- At 50%: /compact preserving modified files, test status, branch, tasks.
- At 70%: commit work, write HANDOFF, new session.
- Read .claude/HANDOFF.md after compact for state recovery.

## Git Workflow

- Branch: `feat/`, `fix/`, `refactor/`, `test/`, `docs/`
- Commits: conventional (`feat:`, `fix:`, `refactor:`, `test:`)
- NEVER commit to `main` or `master` directly.

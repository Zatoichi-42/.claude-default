Read CLAUDE.md completely. Then read every file in .claude/agents/, config/, evals/, and docs/ if they exist in this project.

Identify where we are by reading the project's build sequence in CLAUDE.md (or the nearest equivalent — a TODO.md, a staged spec, or a README with steps). If the project has no explicit build sequence, ask the user before proceeding.

Report which stage and step we are at. Then follow the protocol below without exception.

## Implementation Rules (no exceptions)

1. Follow the project's build sequence exactly. Do not skip steps. Do not build ahead.
2. Begin at the current step, not the first step.
3. After EACH step: run the project's test command (`npm test`, `pytest`, `go test ./...`, etc.). Do not move to the next step until tests pass.
4. When the current stage is fully complete: STOP. Do not begin the next stage.

## Post-Stage Protocol (run in order after every stage completes)

### Step A — Summary

Write a plain-English summary of exactly what was built: files created, functions added, APIs wired, tests written.

### Step B — Simplify

Run /simplify on all changed files.

### Step C — Implementation Audit Table

After simplify completes, read the output files, logs, and source code. Produce this table:

| Item | Complete % | Reason | Suggestion |
| ---- | ---------- | ------ | ---------- |

- **Item**: each feature, function, or requirement from the stage spec
- **Complete %**: 0 / 50 / 100 — no guessing, verify by reading the code
- **Reason**: one sentence — why it is or isn't complete
- **Suggestion**: concrete next action if not 100%, or "none" if done

### Step D — Offer

Ask the user: "Would you like me to implement the suggestions above?"
If yes: implement each suggestion.

$ARGUMENTS

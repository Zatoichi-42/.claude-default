Run the evolution loop for the specified agent or prompt file. No API calls — Claude Code generates mutations and scores them directly.

Usage: /evolve <agent-name> [--iterations N]
Example: /evolve code-reviewer
Example: /evolve summarizer --iterations 5

Steps:

1. Read config/evolution-config.yaml (or project equivalent) for max_per_agent, circuit_breaker, budget caps
2. Read eval thresholds config for ratchet gate thresholds
3. Read eval assertion definitions (evals/ or equivalent)
4. Load current prompt from .claude/agents/{agent-name}.md
5. Run the agent (using Claude Code tools) → write test output to a scratch/iterations/ directory (NOT the canonical output directory) → score output against deterministic assertions
6. Identify the weakest metric (lowest score relative to its threshold)
7. Generate a prompt mutation targeting the weak metric. Strategies: add_constraints, add_examples, tighten_instructions, restructure, calibration_nudge
8. Test the mutation by running the agent again with the new prompt
9. Apply ratchet gate: commit only if weak metric improves by min_improvement AND no other metric regresses by more than max_regression
10. If commit: git commit the .claude/agents/{agent-name}.md change with message `evolve({name}): improve {metric} — {summary}`
11. If revert: restore previous prompt, do NOT commit
12. Log iteration to evolution log (JSONL format)
13. Repeat until: iteration cap reached, circuit breaker triggered (N consecutive non-improvements), or budget exhausted

Eval harness constraint: assertions are deterministic only (schema validation, field presence, numeric thresholds, string patterns). No LLM judge — Claude Code reasons about quality directly during the session.

Report final summary: iterations run, committed/reverted/skipped counts, score trajectory for the weak metric.

$ARGUMENTS

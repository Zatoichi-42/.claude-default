# Agent Spec Template

Agents are markdown files, not code. Claude Code reads them to understand what the agent does, what it produces, and how to evaluate its output.

## How to Define an Agent

Create a file at `.claude/agents/{agent-name}.md` with this structure:

```markdown
# Agent Name

## Mission

One sentence: what does this agent do?

## Inputs

- What data does it read? (files, directories, APIs, web search)
- What arguments does it accept?

## Output Schema

Define the JSON structure the agent must produce:

- Required fields and types
- Confidence score (0.0-1.0)
- Self-evaluation metrics

## Eval Criteria

Binary assertions that can be checked without an LLM judge:

- Schema validity (required fields present, correct types)
- Numeric thresholds (confidence >= 0.6)
- String patterns (ISO timestamp, valid identifiers)
- Completeness checks (minimum sections, minimum length)

## Rules

Hard constraints the agent must follow. Examples:

- Maximum output length
- Required sections
- Forbidden patterns (vague language, hedging, etc.)
- Mandatory adversarial review (disconfirming evidence)
```

## How Agents Work at Runtime

1. The agent runner loads the `.md` file
2. It extracts the prompt, tool permissions, and output schema
3. Claude Code executes the agent using its own tools (file read/write, web search, Bash)
4. Output is written as JSON to the data directory
5. The eval harness runs deterministic assertions against the output
6. Everything is logged to the audit trail

## How Evolution Works

1. Load an agent's `.md` file and its recent eval scores
2. Identify the weakest metric
3. Generate a mutated version targeting the weak metric
4. Run the agent with the mutated prompt against test cases
5. If scores improve without regression: commit the mutation
6. If they regress: discard
7. The `.md` file in git is always the best known version

These files CHANGE OVER TIME. That's the point. They get better.

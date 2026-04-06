Report the current project status:

1. **Build Stage:** Read the project's CLAUDE.md or build sequence. Check what exists in the codebase. Report which stage we're at and what step is next.

2. **Test Status:** Run the project's test command and report results (pass count, fail count, any failures).

3. **Agent Status:** For each agent defined in .claude/agents/ (if any):
   - When was it last run? (check output directories)
   - What are its latest eval scores?
   - Is it above or below threshold?

4. **Evolution Status:** Check for evolution logs (JSONL format):
   - When was the last evolution run?
   - Which agents improved? Which didn't?

5. **Git Status:** Branch, uncommitted changes, recent commits.

6. **Health Checks:**
   - Any lint or type errors?
   - Any stale output files (older than expected)?
   - Any config drift between what's defined and what exists?

Format as a clean summary readable in 30 seconds.

$ARGUMENTS

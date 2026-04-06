---
paths: ["**/*.sh","**/*.env*","**/hooks/**","**/settings.json","**/Dockerfile","**/docker-compose*"]
---
# Safety Rules
1. NEVER hardcode secrets/keys/passwords. 2. NEVER commit .env. 3. NEVER eval user input.
4. NEVER curl|bash. 5. NEVER chmod 777. 6. NEVER disable SSL.
Shell: `#!/usr/bin/env bash`, `set -euo pipefail` (scripts not hooks), quote vars, `[[ ]]`.
Hooks: NEVER exit 1 to block (non-blocking!). Use JSON permissionDecision:"deny" + exit 0.

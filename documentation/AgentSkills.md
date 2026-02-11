**PQ Shared Library — Agent Skills Summary**

- **Purpose**: Provide a concise, human-readable summary of repository-specific rules and automations for AI agents and contributors.

- **Key Rules**:
  - **Branch naming**: `migrate/PascalCaseName` (no hyphens)
  - **File & identifier naming**: PascalCase, no hyphens
  - **Documentation.Name**: hyphenated Verb-Noun allowed (e.g., "New-Batches"); hyphens ONLY here
  - **Rename workflow**: two commits — `git mv` then content commit
  - **Tests**: embed function implementation in test files for portability
  - **Linting**: run PQLint at severity 2; accept/record false positives where justified

- **Actions AI may take (when authorized)**:
  - Create feature branch with correct name
  - Perform `git mv` and create rename commit (ask for approval before pushing)
  - Create or update test files following the embedded-function pattern
  - Run PQLint (via configured MCP) and summarize violations
  - Update `PROJECT_PLAN.md` or `LESSONS_LEARNED.md` when new lessons arise

- **Files created**:
  - `.github/skills/pq-shared-library/SKILL.md` — actionable skill for VS Code/agents
  - `documentation/AgentSkills.md` — brief summary for human readers

- **Next steps you may want**:
  - Install the skill locally by copying `.github/skills/pq-shared-library` to your user skills folder or keeping it in the repo for team use
  - Ask me to open a branch and add a concrete migration example using the two-commit pattern


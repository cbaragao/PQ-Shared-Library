# PQ Shared Library Copilot Instructions

This repository contains Power Query M functions for Power BI. Function implementations are in `functions/`; Power BI-portable test queries are in the matching `tests/` category.

## Repository Rules

- Use PascalCase without hyphens for M identifiers, function filenames, test filenames, and migration branch suffixes.
- Preserve the existing category structure when adding functions or tests.
- Use direct typed function syntax for new or migrated functions. Treat `Function.From` as a legacy pattern to replace during migration.
- Read `LESSONS_LEARNED.md` before changing a migration or reacting to a PQLint finding; some lint findings are documented false positives.
- Use `PROJECT_PLAN.md` to identify migration work and update it only when the migration state changes.
- Keep documentation examples executable: their code must use the actual PascalCase function identifier.

## Git and Validation

- Do not create branches or commits unless requested.
- When a requested migration renames a file, use `git mv` and preserve history with two commits: a rename-only `R100` commit, followed by content and test changes.
- Run PQLint at severity 2 when it is available. Fix genuine findings and record confirmed false positives in `LESSONS_LEARNED.md`.
- Power BI is the authoritative environment for `.query.pq` tests. Do not report manual Power BI test results as passed without user confirmation.

## Scoped Guidance

- Use `.github/instructions/power-query.instructions.md` for `.pq` implementation and test conventions.
- Use `.github/instructions/migration.instructions.md` for migration and rename workflows.

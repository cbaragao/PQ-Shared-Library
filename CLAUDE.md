# PQ Shared Library - Claude Code Instructions

## Project Overview

A Power Query (M Language) function library for Power BI. Functions handle data transformation, statistics, geographic calculations, color/UX utilities. Currently migrating from verbose `Function.From` format to modern direct function syntax.

**Migration status**: 38/44 functions complete (86%). 8 deprecated. 6 remaining.

## Technology

- **Language**: Power Query M (.pq files)
- **Scripts**: PowerShell (.ps1) for automation
- **Tests**: .query.pq files in `tests/` directory
- **No build system** - .pq files are used directly in Power BI

## Repository Structure

```
functions/          # Power Query functions organized by category
  DateTime/, Geo/, Math/, R/, SQL/, String/, Tbl/, Utils/, UX/
tests/              # Test files mirroring functions/ structure
scripts/            # PowerShell automation (wiki generation)
documentation/      # Naming conventions, agent skills
PROJECT_PLAN.md     # Migration tracker
LESSONS_LEARNED.md  # Critical pitfalls and solutions
```

## Naming Conventions (CRITICAL)

| Element            | Pattern           | Hyphens? | Example                  |
|--------------------|-------------------|----------|--------------------------|
| Filename           | PascalCase        | NO       | `NewBatches.pq`          |
| Variable/function  | PascalCase        | NO       | `NewBatches`             |
| Branch name        | PascalCase        | NO       | `migrate/NewBatches`     |
| Test filename      | PascalCase        | NO       | `NewBatches.query.pq`    |
| Documentation.Name | Verb-Noun display | YES      | `"New-Batches"`          |

**Golden rule**: Hyphens ONLY in `Documentation.Name`. M Language identifiers cannot contain hyphens.

Function names follow PowerShell Verb-Noun concepts: Get, Measure, Test, New, Convert/ConvertTo, Remove, Invoke, Add, Update, Select. See `documentation/NamingConventions.md` for the full approved verb list.

## Git Workflow - Two-Commit Pattern (MANDATORY for renames)

Combining `git mv` with content changes in one commit breaks rename tracking. Always:

1. **Commit 1** - Pure rename only: `git mv old.pq new.pq` then commit. Verify `git log --name-status -1` shows `R100`.
2. **Commit 2** - All content modifications, tests, PQLint fixes.
3. **Commit 3** (optional) - Documentation updates.
4. **Merge** - `git merge --no-ff migrate/FunctionName` to preserve branch history.

Note: `.github/` is in `.gitignore`. Use `git add -f` to force-add files there.

## Function File Format

```powerquery
let
  FunctionName = (param1 as type, optional param2 as nullable type) as returnType =>
    let
      // Implementation
    in
      result,
  fnType = type function (param1 as type, optional param2 as nullable type) as returnType
    meta [
      Documentation.Name = "Function-Name",
      Documentation.LongDescription = "Description",
      Documentation.Examples = {
        [
          Description = "Example description",
          Code = "=FunctionName(args)",
          Result = "expected output"
        ]
      }
    ]
in
  Value.ReplaceType(FunctionName, fnType)
```

## Test File Format

Tests embed the parent function directly (NOT Expression.Evaluate + File.Contents) for Power BI portability:

```powerquery
let
    // Embed the function directly in the test file
    FunctionName = (params) as returnType =>
      let
        // Complete function implementation copied here
      in
        result,

    // Test cases
    test1 = FunctionName(testArgs),
    result1 = if [condition] then "Test 1 Passed" else "Test 1 Failed",

    summary = #table(
        {"Test", "Result"},
        {{"Test 1: description", result1}}
    )
in
    summary
```

**Floating point tests**: Never use direct equality. Use tolerance (`Number.Abs(actual - expected) < 0.001`) or rounding (`Number.Round(actual, 4, RoundingMode.AwayFromZero) = expected`).

## M Language Pitfalls

### Number.RoundAwayFromZero - Only 2 parameters
```powerquery
Number.RoundAwayFromZero(value, decimals)        // CORRECT
Number.RoundAwayFromZero(value, decimals, mode)   // WRONG - runtime error
```

### PQLint false positives - These functions do NOT accept Comparer parameters
- `Text.AfterDelimiter` - 3 params max, no comparer
- `Text.Replace` - 3 params max, no comparer
- `Text.StartsWith` - comparer support varies by version, omit for compatibility
- `List.PositionOf` - cannot use BOTH occurrence AND comparer (pick one)

### String escaping
Double quotes escape as `""` not `\"`:
```powerquery
"He said ""hello"""    // CORRECT
"He said \"hello\""    // WRONG
```

### Culture parameters
Add as optional parameters with `"en-US"` default, not hardcoded:
```powerquery
(value as text, optional culture as nullable text) =>
  let _culture = culture ?? "en-US" in ...
```

## Migration Checklist (per function)

1. Check `PROJECT_PLAN.md` for next function
2. Create branch: `migrate/FunctionName`
3. `git mv` old file to new PascalCase name, commit (rename only)
4. Modernize: remove Function.From, use named params, add return types, add MissingField.Ignore to Table ops
5. Update Documentation.Name (hyphenated), Documentation.Examples (no hyphens in code)
6. Create/update test file with embedded function pattern
7. Wait for user to confirm tests pass in Power BI
8. Commit content changes
9. Run PQLint at severity 2, fix genuine issues, document false positives
10. Merge to main with `--no-ff`
11. Update `PROJECT_PLAN.md` with completion status

## Key Reference Files

- `PROJECT_PLAN.md` - Migration progress, remaining functions
- `LESSONS_LEARNED.md` - All pitfalls and solutions (CONSULT BEFORE fixing PQLint issues)
- `documentation/NamingConventions.md` - Approved verbs, renaming guide
- `.github/copilot-instructions.md` - Detailed 12-step migration workflow

# GitHub Copilot Instructions for PQ Shared Library Migration

## Migration Workflow for Power Query Functions

This file contains detailed instructions for migrating Power Query functions from verbose `Function.From` format to simplified syntax with PQLint validation.

### Core Workflow Steps

#### Step 1: Identify Next Migration Task
- Review [PROJECT_PLAN.md](../PROJECT_PLAN.md) to identify the next function to migrate
- Check task status and migration priority
- Confirm with user which function to work on next

#### Step 2: Create Feature Branch
- Branch naming format: `migrate/PascalCaseName` (NO hyphens)
- Example: `migrate/NewBatches`, `migrate/SelectDynamicList`
- **Important**: Branch names use PascalCase WITHOUT hyphens
- Command: `git checkout -b migrate/FunctionName`

#### Step 3: Rename File Using Git Mv (First Commit)
- **CRITICAL**: Use `git mv` command to preserve file history
- **Do NOT create new file and delete old file** - this breaks git rename tracking
- Example workflow:
  ```powershell
  # CORRECT - Preserves file history
  git mv 'functions/Utils/CreateBatches.pq' 'functions/Utils/NewBatches.pq'
  git status  # Should show "renamed: functions/Utils/CreateBatches.pq -> functions/Utils/NewBatches.pq"
  git commit -m "Rename CreateBatches.pq to NewBatches.pq"
  git log --name-status -1  # Should show "R100" (rename with 100% similarity)
  
  # INCORRECT - Breaks file history
  # DO NOT: create_file('NewBatches.pq'); delete old file
  # This shows as "A" (add) + "D" (delete) in git log instead of "R" (rename)
  ```
- **File Naming Convention**:
  - Use PascalCase WITHOUT hyphens: `NewBatches.pq`, `SelectDynamicList.pq`
  - NOT: `New-Batches.pq` ❌ (hyphens not allowed in filenames)
  - See [LESSONS_LEARNED.md#file-naming-convention](../LESSONS_LEARNED.md) for details
- **First commit contains ONLY the rename** - no content changes
- This ensures git recognizes the rename with 100% similarity

#### Step 4: Modify File Content (Second Commit)
- **Now edit the renamed file** with all migration changes:
  1. Remove `Function.From` wrapper
  2. Replace `params{0}, params{1}, params{2}` with named parameters
  3. Add return type annotations (e.g., `() as record`, `as list`)
  4. Update `List.Generate`, `List.Accumulate`, etc. with proper syntax
  5. Add `MissingField.Ignore` to Table operations where needed
  6. Add `Comparer.Ordinal` to text comparison functions
- **Variable Naming**: Use PascalCase matching filename (e.g., `NewBatches`, `SelectDynamicList`)
  - NOT: `New-Batches` ❌ (hyphens cause M Language compilation errors)

#### Step 5: Update Documentation.Name (In Same File)
- **Documentation.Name** uses hyphenated Verb-Noun format: `"New-Batches"`, `"Select-DynamicList"`
- This is the ONLY place where hyphens are used (user-facing display name)
- Update `Documentation.Examples` to use the new function name (without hyphens in code samples)
- Example:
  ```powerquery
  Documentation.Name = "New-Batches",  // Hyphenated for user display
  Documentation.Examples = {
    [
      Code = "=NewBatches(10, 100, 1)"  // No hyphen in actual function call
    ]
  }
  ```

#### Step 6: Verify Git Recognizes Rename
- **Critical verification step before committing modifications**
- Commands:
  ```powershell
  git status  # Should show "renamed: old.pq -> new.pq"
  git log --name-status -1  # Should show "R100" (rename with 100% similarity)
  ```
- If you see "A" (add) + "D" (delete) instead of "R", you broke the rename tracking
- **Fix**: Reset and redo Step 3 using `git mv` properly

#### Step 7: Create Test File (In Second Commit)
- Create test file: `tests/Category/FunctionName.query.pq`
- **File naming**: PascalCase without hyphens (e.g., `NewBatches.query.pq`, `SelectDynamicList.query.pq`)
  - NOT: `New-Batches.query.pq` ❌
- Test file structure:
  ```powerquery
  let
      // Load the function from file
      FunctionName = Expression.Evaluate(Text.FromBinary(File.Contents("functions/Category/FunctionName.pq")), #shared),
      
      // Test cases
      test1 = FunctionName(params),
      result1 = if [condition] then "Test 1 Passed" else "Test 1 Failed",
      
      // Summary table
      summary = #table(
          {"Test", "Result"},
          {
              {"Test 1: description", result1}
          }
      )
  in
      summary
  ```
- **WAIT for user to confirm** all tests pass before proceeding to Step 8
- Do not proceed until user validates results manually

#### Step 8: Commit Content Changes (Second Commit)
- Stage changes and commit:
  ```powershell
  git add functions/Utils/NewBatches.pq tests/Utils/NewBatches.query.pq
  git commit -m "Migrate NewBatches to modern syntax with PQLint compliance
  
  - Removed Function.From wrapper
  - Replaced params{0-2} with named parameters
  - Added return type annotations
  - Added MissingField.Ignore to Table operations
  - Updated Documentation.Name to 'New-Batches'
  - Created comprehensive test suite
  - Variable name: NewBatches (PascalCase, no hyphen)
  - All tests passed, PQLint validation: 0 violations"
  ```
- Verify: `git log --name-status -2` should show:
  - First commit: `R100 functions/Utils/CreateBatches.pq functions/Utils/NewBatches.pq`
  - Second commit: `M functions/Utils/NewBatches.pq` and `A tests/Utils/NewBatches.query.pq`

#### Step 9: Run PQLint Validation
- Use MCP PQLint server with severity level 2:
  ```typescript
  mcp_pqlint-mcp_lint_code({
    code: [file content],
    severity: "2"
  })
  ```
- Address any violations (see [LESSONS_LEARNED.md](../LESSONS_LEARNED.md) for common fixes)
- **If PQLint violations found**: Fix them and amend the second commit or create a new commit
- Re-run tests after fixes to ensure no regressions
- **WAIT for user confirmation** that fixes don't break tests

#### Step 10: Update Documentation (Optional Third Commit)
- If major lessons learned or workflow changes discovered:
  - Update [LESSONS_LEARNED.md](../LESSONS_LEARNED.md)
  - Update this file (.github/copilot-instructions.md) if workflow changes
  - Commit documentation updates separately:
    ```powershell
    git add -f .github/copilot-instructions.md LESSONS_LEARNED.md
    git commit -m "Update documentation for NewBatches migration"
    ```
  - Note: `.github` is in `.gitignore`, use `git add -f` to force add

#### Step 11: Merge to Main
- Switch to main and merge using `--no-ff` (no fast-forward):
  ```powershell
  git checkout main
  git merge --no-ff migrate/NewBatches -m "Merge NewBatches migration"
  ```
- This preserves the feature branch history in the commit graph

#### Step 12: Update Progress
- Update [PROJECT_PLAN.md](../PROJECT_PLAN.md):
  - Mark task as completed
  - Update progress percentage
  - Update task counts
- Commit the update:
  ```powershell
  git add PROJECT_PLAN.md
  git commit -m "Update PROJECT_PLAN.md: Task XX completed (FunctionName) - YY/44 functions (ZZ% progress)"
  ```

### Summary: Two-Commit Workflow Pattern

This approach ensures proper git rename tracking while allowing significant code changes:

1. **Commit 1**: Pure rename with `git mv` → Shows as "R100" in git log
2. **Commit 2**: All content changes (modernization, PQLint fixes, tests) → Shows as "M"
3. **Commit 3** (optional): Documentation updates

**Why This Matters**:
- Preserves file history across renames (git log --follow works correctly)
- GitHub shows file evolution, not file replacement
- Critical for future documentation and code archaeology
- Maintains clean, traceable git history

### File Naming Summary

| Element | Pattern | Hyphen? | Example |
|---------|---------|---------|---------|
| Filename | PascalCase | ❌ NO | `NewBatches.pq` |
| Variable Name | PascalCase | ❌ NO | `NewBatches` |
| Branch Name | PascalCase | ❌ NO | `migrate/NewBatches` |
| Documentation.Name | Verb-Noun | ✅ YES | `"New-Batches"` |
| Test Filename | PascalCase | ❌ NO | `NewBatches.query.pq` |

**Golden Rule**: Hyphens ONLY in `Documentation.Name` (user-facing string literal). Everything else uses PascalCase without hyphens.

### Key References
- [LESSONS_LEARNED.md](../LESSONS_LEARNED.md) - All migration issues and solutions
- [PROJECT_PLAN.md](../PROJECT_PLAN.md) - Migration progress and task list
- [NamingConventions.md](../documentation/NamingConventions.md) - PowerShell approved verbs
- PQLint MCP Server - Linting rules and validation

### Common PQLint Fixes
See [LESSONS_LEARNED.md#common-pqlint-rules-reference](../LESSONS_LEARNED.md#common-pqlint-rules-reference) for detailed solutions to:
- Missing culture parameters
- Number.Round rounding mode
- Comparer.Ordinal for text operations
- Return type annotations
- MissingField.Ignore for Table operations

**Critical Migration Warning:**
- `Number.RoundAwayFromZero` only accepts two parameters: value and decimals. Do NOT add a third parameter (e.g., `RoundingMode.AwayFromZero`). This causes runtime errors. Always check for this mistake in migrated code and tests.

**Migration Checklist Addition:**
- Review all migrated Power Query code and tests for incorrect third parameter usage in `Number.RoundAwayFromZero`. Fix immediately if found.

---

## Last Updated
2026-02-09 - Added two-commit workflow for proper git rename tracking

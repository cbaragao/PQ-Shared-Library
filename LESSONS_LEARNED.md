# Lessons Learned - PQ Shared Library Migration

This document tracks all issues, errors, and solutions encountered during the migration of Power Query functions from verbose `Function.From` format to simplified syntax with PQLint validation.

---

## Overview
- **Purpose**: Track recurring issues and their solutions to avoid solving the same problem multiple times
- **Usage**: Always consult this file before addressing a new PQLint error or migration issue
- **Update**: Add new lessons immediately when encountered

---

## Template for New Entries

```markdown
### Issue: [Brief Description]
- **Date**: YYYY-MM-DD
- **Function(s)**: FunctionName(s) affected
- **Category**: [Syntax | PQLint | Documentation | Git | Other]
- **Severity**: [Critical | High | Medium | Low]
- **Problem**: Detailed description of the issue
- **Solution**: How it was resolved
- **Prevention**: How to avoid this in the future
```

---

## Logged Issues

### Issue: Missing Culture Parameters for Date/Time and Numeric Functions
- **Date**: 2026-02-07
- **Function(s)**: RoundDateTime
- **Category**: PQLint
- **Severity**: Medium
- **Problem**: PQLint rule `use-culture-for-date-functions` and `use-culture-for-numeric-functions` flagged missing culture parameter in `Number.From()` and `DateTime.From()` functions. Without explicit culture, output may vary based on user's machine locale.
- **Solution**: Add `"en-US"` as second parameter to both `Number.From(dt, "en-US")` and `DateTime.From(Rounded, "en-US")` to ensure predictable output regardless of user locale.
- **Prevention**: Always include culture parameter when using date/time or numeric conversion functions. Default to `"en-US"` unless specific locale is required.

### Issue: RoundDateTime Logic Error - Wrong Rounding Function Used
- **Date**: 2026-02-07
- **Function(s)**: RoundDateTime
- **Category**: Logic Bug
- **Severity**: Critical
- **Problem**: Function used `Number.RoundAwayFromZero` which always rounds away from zero, causing incorrect results. Test case: `RoundDateTime(#datetime(2022, 10, 1, 10, 17, 55), 15)` expected `#datetime(2022, 10, 1, 10, 15, 0)` but returned `#datetime(2022, 10, 1, 10, 30, 0)`. The function should round to the NEAREST interval, not always away from zero.
- **Solution**: Replace `Number.RoundAwayFromZero` with `Number.Round` to properly round to the nearest value.
- **Prevention**: ALWAYS create test files (in `tests/Category/FunctionName.query.pq`) and validate function output against Documentation.Examples BEFORE considering migration complete. Test-driven development prevents these bugs.

### Issue: Missing Testing Step in Migration Workflow
- **Date**: 2026-02-07
- **Function(s)**: All functions
- **Category**: Process
- **Severity**: Critical
- **Problem**: Original workflow didn't include functional testing step. Functions passed linting but had logic errors that weren't caught until user tested manually.
- **Solution**: Updated workflow to include creating test files in `tests/Category/` directory and validating results match Documentation.Examples before committing. Test files must be **self-contained** (include the function being tested as a nested function) to ensure we're testing the exact code being committed. Added step to WAIT for manual test confirmation from user before proceeding to linting.
- **Prevention**: Never skip testing. Create self-contained test files with the function code embedded, test cases from documentation examples, and **WAIT for user to manually validate** all Pass columns are true using Power Query SDK BEFORE proceeding to lint and commit.

### Issue: Test Files Must Be Self-Contained
- **Date**: 2026-02-07
- **Function(s)**: All functions
- **Category**: Testing
- **Severity**: High
- **Problem**: Test files that reference external functions can't validate the exact code being tested. Need to ensure test file contains the function implementation.
- **Solution**: Each `.query.pq` test file must include the function being tested as a nested function (copy the simplified function logic without type metadata). This ensures tests are portable and validate the exact code that will be committed.
- **Prevention**: Always copy the function implementation into the test file. Test file structure: 1) Function definition, 2) Test cases table with Expected/Actual/Pass columns, 3) Return the test table.

### Issue: Number.Round Default Banker's Rounding Behavior
- **Date**: 2026-02-07
- **Function(s)**: RoundDateTime
- **Category**: PQLint
- **Severity**: High
- **Problem**: PQLint rule `use-specific-parameter-for-number-round` flagged that `Number.Round` uses banker's rounding (RoundingMode.ToEven) by default, which rounds 0.5 to nearest even number. This could cause unexpected results.
- **Solution**: Explicitly specify `RoundingMode.AwayFromZero` as third parameter: `Number.Round((Source * Minutes), 0, RoundingMode.AwayFromZero)`. This provides standard mathematical rounding behavior.
- **Prevention**: Always specify the rounding mode parameter when using `Number.Round` to avoid ambiguity and ensure predictable behavior.

### Issue: Culture Parameters Should Be Optional, Not Hardcoded
- **Date**: 2026-02-07
- **Function(s)**: Test-Benford, ConvertTo-RoundedDateTime
- **Category**: Best Practice
- **Severity**: High
- **Problem**: Initially hardcoded culture parameters as `"en-US"` in function calls like `Text.From(num, "en-US")`. This makes functions inflexible and doesn't allow users to specify different cultures when needed.
- **Solution**: Add optional culture parameter to function signature: `(num as number, optional culture as nullable text)`. Use null-coalescing operator to set default: `_culture = culture ?? "en-US"`. Then use `_culture` variable throughout function. This provides flexibility while maintaining predictable default behavior.
- **Prevention**: When PQLint flags missing culture parameters, don't hardcode them. Instead, add an optional culture parameter with "en-US" as the default value using the null-coalescing operator (`??`). Update both function signature and type definition to include `optional culture as nullable text`. See Microsoft Learn docs on optional parameters for pattern.

---

## Common PQLint Rules Reference

This section will be populated with frequently encountered PQLint rules and how to fix them.

### Example Format:
```markdown
#### Rule PQ-XXXX: [Rule Name]
- **Description**: What the rule checks
- **Common Causes**: Typical scenarios that trigger this rule
- **Fix**: How to resolve
- **Example**:
  ```powerquery
  // Before (incorrect)
  [bad code example]
  
  // After (correct)
  [good code example]
  ```
```

### Issue: M Language Identifiers Cannot Contain Hyphens
- **Date**: 2026-02-07
- **Function(s)**: All migrated functions (GetFactors, ConvertToRoundedDateTime, MeasureBearing, MeasureDistance, TestBenford, GetConfidenceInterval)
- **Category**: Syntax
- **Severity**: Critical
- **Problem**: Initially attempted to use PowerShell-style Verb-Noun naming with hyphens (e.g., `Get-Factors`, `Measure-Distance`) as M Language identifiers. However, M Language does not allow hyphens in identifiers - they cause compilation errors. This created inconsistency where `Documentation.Name` showed `"Get-Factors"` but users had to call the function as `GetFactors()`, leading to confusion.
- **Solution**: 
  1. Use the identifier name (without hyphens) consistently throughout: `GetFactors`, `MeasureBearing`, `TestBenford`, etc.
  2. In `Documentation.Name`, use the same identifier name: `"GetFactors"` not `"Get-Factors"`
  3. In `Documentation.Examples`, code samples must show actual function calls: `GetFactors(28)` not `Get-Factors(28)`
  4. Updated all previously migrated functions to fix documentation inconsistencies
- **Prevention**: 
  - Remember that M Language identifiers follow standard programming naming rules (alphanumeric + underscore only)
  - Documentation should always reflect the ACTUAL function call syntax users will use
  - PowerShell-style Verb-Noun naming is a conceptual guide for choosing descriptive names, not a literal syntax requirement
  - Test files serve as validation that documentation matches actual usage

---

## Migration Pattern Library

Common patterns and their simplified equivalents will be documented here as they're discovered.

_To be populated during migration._

---

## Git/Branch Management Issues

_To be populated with any git-related issues encountered._

---

## Last Updated
This document was created on 2026-02-07 and will be updated throughout the migration process.

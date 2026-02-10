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
- **Function(s)**: ConvertToRoundedDateTime
- **Category**: PQLint
- **Severity**: Medium
- **Problem**: PQLint rule `use-culture-for-date-functions` and `use-culture-for-numeric-functions` flagged missing culture parameter in `Number.From()` and `DateTime.From()` functions. Without explicit culture, output may vary based on user's machine locale.
- **Solution**: Add `"en-US"` as second parameter to both `Number.From(dt, "en-US")` and `DateTime.From(Rounded, "en-US")` to ensure predictable output regardless of user locale.
- **Prevention**: Always include culture parameter when using date/time or numeric conversion functions. Default to `"en-US"` unless specific locale is required.

### Issue: ConvertToRoundedDateTime Logic Error - Wrong Rounding Function Used
- **Date**: 2026-02-07
- **Function(s)**: ConvertToRoundedDateTime
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
- **Function(s)**: ConvertToRoundedDateTime
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

### Issue: Power Query String Literals Use Double Quote Escaping
- **Date**: 2026-02-07
- **Function(s)**: MeasureCorrelation
- **Category**: Syntax
- **Severity**: Medium
- **Problem**: In `Documentation.Examples`, attempted to escape double quotes using backslash (`\"`) like in many other languages. Power Query M Language uses a different escaping mechanism - double quotes are escaped by doubling them (`""`).
- **Solution**: Replace `\"A\"` with `""A""` in string literals. For example:
  - Incorrect: `"MeasureCorrelation(#table({\"A\", \"B\"}, {{1, 2}}))"` 
  - Correct: `"MeasureCorrelation(#table({""A"", ""B""}, {{1, 2}}))"`
- **Prevention**: Remember M Language string escaping rules - to include a double quote character inside a string literal, use two consecutive double quotes (`""`), not backslash escape sequences.

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

### Issue: Function Better Implemented in Different Tool (Corr/MeasureCorrelation)
- **Date**: 2026-02-07
- **Function(s)**: Corr (attempted migration to MeasureCorrelation)
- **Category**: Architecture Decision
- **Severity**: High
- **Problem**: Attempted to migrate Corr function for generating correlation matrices. After multiple debugging iterations with syntax issues for Table.FromList, Table.TransformColumnTypes, Table.RenameColumns, and Table.ReorderColumns, realized that correlation matrices are computationally expensive and better suited for DAX rather than Power Query M Language.
- **Solution**: Deprecated the function entirely. Removed from migration plan. Users should use DAX functions like CORREL.X() or create calculated columns/tables in Power BI for statistical correlation analysis.
- **Prevention**: 
  - Before migrating complex statistical functions, evaluate whether Power Query is the right tool
  - Power Query is optimized for data transformation, not complex statistical computation
  - DAX is better suited for calculations that need to happen in the data model
  - Consider the use case: if function is primarily used in Power BI, DAX may be more appropriate
  - Avoid spending extensive time debugging functions that would be better implemented elsewhere

### Issue: Obsolete Hardcoded Lookup Tables (Z.pq)
- **Date**: 2026-02-07
- **Function(s)**: Z (Z-score lookup table)
- **Category**: Architecture Decision
- **Severity**: High
- **Problem**: The Z.pq function contains an 832-line hardcoded Z-score lookup table copied from a static reference table. This approach is inefficient, difficult to maintain, and completely unnecessary given modern statistical function capabilities in Excel, Power BI, and other tools.
- **Solution**: Deprecated the function entirely. Removed from migration plan. Users should use native statistical distribution functions instead:
  - Excel: NORM.S.DIST() for cumulative probability, NORM.S.INV() for inverse
  - Power BI DAX: NORM.DIST(), NORM.INV()
  - These functions calculate values dynamically with precision, no lookup table needed
- **Prevention**:
  - Recognize when a function is solving a problem that no longer exists in modern tools
  - Hardcoded lookup tables with hundreds of rows are red flags for deprecation
  - Before migrating statistical functions, check if Excel/Power BI have built-in equivalents
  - Consider maintainability: static lookup tables become obsolete as native capabilities improve
  - Evaluate whether the function provides value beyond what's already available in the platform

### Issue: Complex Statistical Functions Better Implemented in DAX (MegaAverage, MegaStDevS, Pearson, QuartileStats)
- **Date**: 2026-02-07
- **Function(s)**: MegaAverage, MegaStDevS, Pearson, QuartileStats
- **Category**: Architecture Decision
- **Severity**: High
- **Problem**: These functions perform complex statistical calculations (trimmed/geometric/winsorized averages and standard deviations, Pearson correlation, quartile analysis with outlier detection). While technically functional in Power Query, they represent statistical analysis that should happen in the data model layer, not the ETL layer.
- **Solution**: Deprecated all 4 functions. Rationale:
  - **MegaAverage/MegaStDevS**: Return statistical records with multiple calculation types. These are aggregations that should be dynamic DAX measures, not static transformations.
  - **Pearson**: Correlation calculations similar to already-deprecated Corr function. DAX correlation functions are more appropriate.
  - **QuartileStats**: Power Query has `List.Percentile()` built-in. DAX has `PERCENTILE.INC()` and `PERCENTILE.EXC()`. Outlier detection belongs in visualization layer.
  - Users should implement these in DAX where they can be:
    - Dynamic and respond to filters/slicers
    - Calculated across the entire data model
    - Optimized by the analysis engine
    - Easier to maintain and update
- **Prevention**:
  - Power Query is for data **transformation**, not statistical **analysis**
  - If a function returns complex statistical metrics, consider if it belongs in DAX
  - Ask: "Does this calculation need to be static in the data, or dynamic in reports?"
  - Statistical aggregations that produce multiple metrics → DAX measures
  - Data cleaning/preparation based on statistics → might be appropriate for Power Query
  - When in doubt, favor DAX for calculations that end-users might want to filter or customize

### Issue: PQLint False Positive for List.Generate Each Expressions
- **Date**: 2026-02-07
- **Function(s)**: GetErlangC
- **Category**: PQLint
- **Severity**: Low
- **Problem**: PQLint rule `no-return-type-for-function` flagged the `each` expression in `List.Generate` as missing a return type annotation. The tool suggested adding `as record` to the each expression. However, the `each` keyword in `List.Generate` is not a standalone function definition - it's an iteration expression where Power Query infers the type from context.
- **Solution**: Accepted as false positive. The code `each [Agents = ..., Service_Level = ...]` is correct without explicit type annotation. The linting rule is designed for top-level function definitions, not inline iteration expressions within built-in functions like List.Generate.
- **Prevention**: 
  - Recognize that not all PQLint warnings require code changes
  - Inline expressions within higher-order functions (List.Generate, List.Accumulate, List.Transform, etc.) don't always need explicit return types
  - Evaluate whether a linting violation represents a genuine issue or an overly strict interpretation
  - Document false positives to avoid confusion in future migrations

### Issue: Floating Point Precision in Test Assertions
- **Date**: 2026-02-07
- **Function(s)**: CalculateEWMA, TestBenford, GetConfidenceInterval
- **Category**: Testing
- **Severity**: Medium
- **Problem**: Test cases for mathematical functions that produce floating point results can fail due to IEEE 754 precision limits. For example, an EWMA calculation produced `52.640000000000008` instead of expected `52.64`. Direct comparison (`actual = expected`) fails even though results are mathematically equivalent.
- **Solution**: Use one of two valid approaches to handle floating point precision:
  
  **Approach 1 - Tolerance-based comparison** (using `Number.Abs()`):
  ```powerquery
  Number.Abs(TestBenford(123)[Digit_One] - 0.30103) < 0.001
  ```
  This checks if values are within an acceptable tolerance (e.g., 0.001). More flexible since it doesn't require knowing exact decimal places.
  
  **Approach 2 - Rounding-based comparison** (using `Number.Round()`):
  ```powerquery
  Number.Round(CalculateEWMA(...), 4, RoundingMode.AwayFromZero) = 52.64
  ```
  This rounds to a specific precision before comparing. Ensures predictable rounding behavior (standard mathematical rounding, not banker's rounding).
  
- **Prevention**:
  - **Never use direct equality** (`actual = expected`) for floating point numbers
  - **Choose approach based on context**:
    - Tolerance-based: Better when acceptable variance is known (e.g., "within 0.001 is close enough")
    - Rounding-based: Better when expected values have fixed decimal places (e.g., always 4 decimals)
  - **If using Number.Round()**: Always include `RoundingMode.AwayFromZero` for standard mathematical rounding
  - Default `Number.Round()` uses banker's rounding (RoundingMode.ToEven), which can produce unexpected results
  - Apply rounding to both the Actual column AND the Pass comparison
  - Reference: https://excelguru.ca/power-query-the-round-function/ for Power Query rounding behavior

### Issue: Redundant Type Conversions Trigger PQLint Warnings
- **Date**: 2026-02-07
- **Function(s)**: CalculateEWMA
- **Category**: PQLint
- **Severity**: Low
- **Problem**: PQLint rule `use-culture-for-numeric-functions` flagged `Number.From()` calls even though parameters were already typed as numbers: `alpha * Number.From(current) + (1 - alpha) * Number.From(List.Last(state))`. When values are already the correct type, conversion functions are redundant.
- **Solution**: Remove unnecessary `Number.From()` calls when parameters have explicit type annotations. Simplified to: `alpha * current + (1 - alpha) * List.Last(state)`. Since `current as number` and `state` contains numbers, conversions are not needed.
- **Prevention**:
  - Check parameter type annotations before using conversion functions
  - If a parameter is already typed (e.g., `current as number`), don't wrap it in `Number.From()`
  - If a function is typed to return a specific type, trust that type
  - Only use conversion functions when dealing with `any` type or mixed-type lists
  - Redundant conversions add noise and can trigger linting rules about culture parameters

---

## Migration Pattern Library

Common patterns and their simplified equivalents will be documented here as they're discovered.

_To be populated during migration._

---

## Git/Branch Management Issues

### Issue: Git Rename Detection Fails When Rename and Modification Combined in Single Commit
- **Date**: 2026-02-09
- **Function(s)**: NewBatches, SelectDynamicList (initial attempts)
- **Category**: Git
- **Severity**: Critical
- **Problem**: When performing `git mv CreateBatches.pq NewBatches.pq` and then editing the renamed file in the same commit, git's rename detection fails. Git log shows "A" (add) and "D" (delete) instead of "R" (rename), breaking file history tracking. GitHub shows these as unrelated files rather than a rename with modifications. This is critical for documentation and code history.
- **Root Cause**: Git's rename detection threshold requires >50% similarity. When you rename AND significantly modify the file content in one commit (e.g., removing Function.From wrapper, changing parameter names from params{0} to named params), the content similarity drops below 50%, causing git to interpret it as delete + new file.
- **Solution**: Use two-commit workflow:
  1. **First commit**: Pure rename only using `git mv`
     ```powershell
     git mv 'functions/Utils/CreateBatches.pq' 'functions/Utils/NewBatches.pq'
     git commit -m "Rename CreateBatches.pq to NewBatches.pq"
     git log --name-status -1  # Verify shows "R100" (100% similarity)
     ```
  2. **Second commit**: Modify content (migration to simplified syntax)
     ```powershell
     # Edit functions/Utils/NewBatches.pq with all changes
     git add functions/Utils/NewBatches.pq tests/Utils/NewBatches.query.pq
     git commit -m "Migrate NewBatches to modern syntax with PQLint compliance"
     git log --name-status -2  # First commit shows R100, second shows M
     ```
  3. **(Optional) Third commit**: Documentation and meta-file updates
     ```powershell
     git add LESSONS_LEARNED.md .github/copilot-instructions.md
     git commit -m "Update documentation for NewBatches migration"
     ```
- **Prevention**:
  - **NEVER combine git mv and file edits in the same commit**
  - First commit must be the bare `git mv` command with NO content changes
  - Verify rename tracked: `git log --name-status -1` should show "R100", not "A" and "D"
  - After first commit, edit the renamed file and commit modifications separately
  - This two-commit pattern is MANDATORY for proper git history
  - Critical for documentation: rename tracking shows function evolution, not file replacement
- **Verification Commands**:
  ```powershell
  git log --name-status -1  # Should show "R100" for rename commit
  git log --name-status -2  # Second commit shows "M" for modifications
  git log --follow functions/Utils/NewBatches.pq  # Shows full history including old filename
  ```

### Issue: File Naming Convention - PascalCase Required, No Hyphens Allowed
- **Date**: 2026-02-09
- **Function(s)**: NewBatches, SelectDynamicList (initial attempts)
- **Category**: File Naming
- **Severity**: High
- **Problem**: Initially created files with hyphenated names: `New-Batches.pq`, `Select-DynamicList.pq`. This is incorrect for two reasons:
  1. M Language identifiers cannot contain hyphens (compilation error)
  2. Creates confusion between filename, variable name, and documentation name
  3. File naming convention should follow standard programming patterns (PascalCase without special characters)
- **Incorrect Pattern**:
  - Filename: `New-Batches.pq` ❌
  - Variable name: `New-Batches` ❌ (compilation error)
  - Documentation.Name: `"New-Batches"` ✓ (user-facing display name, hyphens allowed)
- **Correct Pattern**:
  - Filename: `NewBatches.pq` ✓ (PascalCase, no hyphen)
  - Variable name: `NewBatches` ✓ (matches filename)
  - Documentation.Name: `"New-Batches"` ✓ (hyphenated Verb-Noun format for user-facing docs)
- **Solution**:
  1. File names use PascalCase without hyphens: **NewBatches.pq**, **SelectDynamicList.pq**
  2. Variable names match file names exactly: **NewBatches**, **SelectDynamicList**
  3. Only Documentation.Name uses hyphenated Verb-Noun format: **"New-Batches"**, **"Select-DynamicList"**
  4. Test files follow same pattern: **NewBatches.query.pq**, **SelectDynamicList.query.pq**
- **Prevention**:
  - Remember: Hyphens ONLY in Documentation.Name (user-facing string literal)
  - Filenames, variable names, function names: PascalCase WITHOUT hyphens
  - Verify filename after `git mv`: `git status` should show correct PascalCase with no hyphens
  - PowerShell Verb-Noun naming is a CONCEPTUAL guide (New, Select, Get, etc.), not literal syntax
- **Examples for Migration Tasks**:
  | Old Name | New File Name | Variable Name | Documentation.Name |
  |----------|---------------|---------------|-------------------|
  | CreateBatches.pq | NewBatches.pq | NewBatches | "New-Batches" |
  | fnDynamicSelectList.pq | SelectDynamicList.pq | SelectDynamicList | "Select-DynamicList" |
  | GetFunctionMetadata.pq | GetFunctionMetadata.pq | GetFunctionMetadata | "Get-FunctionMetadata" |
  | PostRequest.pq | PostRequest.pq | PostRequest | "Post-Request" |

_To be populated with any git-related issues encountered._

---

## Test File Pattern Issues

### Issue: Expression.Evaluate Pattern Creates File Dependencies for Power BI Testing
- **Date**: 2026-02-09
- **Function(s)**: All UX category functions (15 functions total)
- **Category**: Testing
- **Severity**: High
- **Problem**: Test files initially used `Expression.Evaluate(Text.FromBinary(File.Contents("functions/UX/FunctionName.pq")), #shared)` to load the parent function. This pattern creates file system dependencies that make testing difficult in Power BI Desktop where file paths may not be accessible or may differ from development environment. Users reported: "I don't understand this test at all" and "Why are we using expression.evaluate? Please nest the function in the file"
- **Root Cause**: Expression.Evaluate with File.Contents() was chosen for maintainability (single source of truth for function logic) but creates practical testing barriers. When users copy test files to Power BI, the file paths break, making tests unusable without the full folder structure.
- **Solution**: Embed the parent function directly in the test file instead of using Expression.Evaluate:
  
  **Old Pattern** (Expression.Evaluate):
  ```powerquery
  let 
      // Load the function from file
      GetColorHue = Expression.Evaluate(Text.FromBinary(File.Contents("functions/UX/GetColorHue.pq")), #shared),
      
      // Test cases
      test1 = GetColorHue("#FF0000")
  ```
  
  **New Pattern** (Embedded Function):
  ```powerquery
  let 
      // Define the function directly in the test file
      GetColorHue = (HEX as text, optional culture as nullable text) as number =>
        let
          // [complete function implementation]
        in
          result,
      
      // Test cases
      test1 = GetColorHue("#FF0000")
  ```
  
- **Impact**: Updated all 9 remaining UX test files to use embedded pattern:
  - GetCompColor.query.pq
  - GetFontColor.query.pq
  - GetHexValue.query.pq
  - GetLuminosity.query.pq
  - GetRGBValue.query.pq
  - MedianAspectRatio.query.pq
  - TestColorBlindness.query.pq
  - TestColorContrast.query.pq
  - TestWebAimContrast.query.pq
  
- **Prevention**:
  - Always embed the parent function directly in test files for portable, self-contained testing
  - Test files must be usable in Power BI Desktop without external file dependencies
  - Prioritize user testing experience over single-source-of-truth maintainability
  - When creating new test files, copy the complete function implementation (without Value.ReplaceType wrapper)
  - Add comment: `// Define the function directly in the test file` at the top
  
- **Trade-offs Accepted**:
  - **Pro**: Test files are now portable and work in any Power BI environment
  - **Pro**: Users can easily understand complete test logic without navigating multiple files
  - **Con**: Function logic is duplicated between parent .pq file and test file
  - **Con**: If parent function changes, test file must be manually updated
  - Decision: Portability and ease of testing outweigh single-source-of-truth concerns

---

## Parameter Signature Validation Errors

### Issue: Text.AfterDelimiter Does Not Accept Comparer Parameter
- **Date**: 2026-02-09
- **Function(s)**: GetColorHue, GetCompColor, GetFontColor, GetLuminosity, GetRGBValue, TestColorBlindness, TestColorContrast
- **Category**: PQLint False Positive / Parameter Signature Error
- **Severity**: Critical
- **Problem**: PQLint recommended adding `Comparer.Ordinal` to `Text.AfterDelimiter` calls for culture-insensitive text operations. However, `Text.AfterDelimiter` only accepts 3 parameters: `(text, delimiter, index)` - it does NOT have a comparer parameter. Adding `Comparer.Ordinal` as a 4th parameter caused runtime error: **"Expression.Error: 4 arguments were passed to a function which expects between 2 and 3"**
  
  **Incorrect code** (based on PQLint recommendation):
  ```powerquery
  Source = Text.Upper(Text.AfterDelimiter(Text.From(HEX, cultureToUse), "#", 0, Comparer.Ordinal))
  ```
  
  **Correct code**:
  ```powerquery
  Source = Text.Upper(Text.AfterDelimiter(Text.From(HEX, cultureToUse), "#", 0))
  ```
  
- **Root Cause**: PQLint's culture/comparer rules are overly broad and don't account for actual Power Query function signatures. Not all text functions accept comparer parameters.
  
- **Solution**: Remove `Comparer.Ordinal` from all `Text.AfterDelimiter` calls. The function doesn't support it, and text comparison is handled by the delimiter parameter (which is a simple string match).
  
- **Prevention**:
  - **Always verify function signatures** before implementing PQLint recommendations
  - Use Microsoft Learn documentation to confirm parameter lists: https://learn.microsoft.com/en-us/powerquery-m/text-afterdelimiter
  - **Text.AfterDelimiter signature**: `Text.AfterDelimiter(text as nullable text, delimiter as text, optional index as any) as nullable text`
  - No comparer parameter exists for this function
  - When PQLint suggests adding culture/comparer parameters, TEST the code before committing
  
- **Related Functions Affected**: Any function using `Text.AfterDelimiter` with hex color parsing

### Issue: List.PositionOf Cannot Use Both Occurrence and Comparer Simultaneously
- **Date**: 2026-02-09
- **Function(s)**: GetColorHue, GetCompColor, GetFontColor, GetLuminosity, GetRGBValue, TestColorBlindness, TestColorContrast
- **Category**: Parameter Signature Error
- **Severity**: Critical
- **Problem**: Attempted to use `List.PositionOf(RGB, hexlist{0}, Occurrence.First, Comparer.Ordinal)` expecting 4 parameters. However, the function signature is overloaded and accepts EITHER:
  - `List.PositionOf(list, value)` - 2 parameters
  - `List.PositionOf(list, value, occurrence)` - 3 parameters (NO comparer)
  - `List.PositionOf(list, value, comparer)` - 3 parameters (NO occurrence)
  
  Passing both Occurrence.First AND Comparer.Ordinal caused runtime error: **"Expression.Error: We cannot convert a value of type Function to type Number"** (Power Query tried to interpret Comparer.Ordinal as a number parameter)
  
  **Incorrect code**:
  ```powerquery
  r1 = List.PositionOf(RGB, hexlist{0}, Occurrence.First, Comparer.Ordinal)
  ```
  
  **Correct code**:
  ```powerquery
  r1 = List.PositionOf(RGB, hexlist{0})
  ```
  
- **Root Cause**: Misunderstanding of function overloads. `List.PositionOf` has multiple signatures but doesn't accept both occurrence and comparer in the same call. Additionally, Occurrence.First and Comparer.Ordinal were not needed because:
  1. Hex strings are already uppercased (`Text.Upper()` applied before splitting)
  2. RGB list values are already uppercase (`{"A".."F"}`)
  3. Each character appears only once in the position being searched
  
- **Solution**: Remove both `Occurrence.First` and `Comparer.Ordinal` - use the simplest 2-parameter form of `List.PositionOf(RGB, hexlist{X})` since the search value is guaranteed unique and case-matched.
  
- **Prevention**:
  - Check Microsoft Learn for function overload signatures: https://learn.microsoft.com/en-us/powerquery-m/list-positionof
  - **List.PositionOf signatures**:
    - `List.PositionOf(list as list, value as any, optional occurrence as nullable number) as any`
    - `List.PositionOf(list as list, value as any, optional equationCriteria as any) as any`
  - Cannot use both `occurrence` and `equationCriteria` (comparer) simultaneously
  - When values are pre-normalized (e.g., already uppercased), additional parameters are redundant
  - Test runtime behavior when combining optional parameters from PQLint recommendations
  
### Issue: Text.Replace Does Not Accept Comparer Parameter
- **Date**: 2026-02-09
- **Function(s)**: GetColorScheme
- **Category**: Parameter Signature Error
- **Severity**: High
- **Problem**: Added `Comparer.Ordinal` to `Text.Replace` calls based on PQLint culture-insensitive recommendations. However, `Text.Replace` only accepts 3 parameters: `(text, old, new)` - no comparer parameter exists. Runtime error: **"Expression.Error: 3 arguments were passed to a function which expects between 1 and 2"** (error message itself is confusing, but root cause is invalid parameter count).
  
  **Incorrect code**:
  ```powerquery
  remove = Text.Replace(trim, " ", "", Comparer.Ordinal)
  ```
  
  **Correct code**:
  ```powerquery
  remove = Text.Replace(trim, " ", "")
  ```
  
- **Solution**: Remove `Comparer.Ordinal` from all `Text.Replace` calls. Simple string replacement doesn't need culture-specific comparison.
  
- **Prevention**:
  - Verify `Text.Replace` signature: `Text.Replace(text as nullable text, old as text, new as text) as nullable text`
  - No comparer parameter available
  - Reference: https://learn.microsoft.com/en-us/powerquery-m/text-replace
  
### Issue: Text.StartsWith Comparer Parameter Not Consistently Supported
- **Date**: 2026-02-09
- **Function(s)**: GetColorScheme, TestWebAimContrast
- **Category**: Parameter Signature Error
- **Severity**: Medium
- **Problem**: Some Power Query versions support `Text.StartsWith(text, substring, comparer)` while others don't, causing inconsistent behavior across environments. Using `Comparer.Ordinal` caused failures in some test scenarios.
  
  **Version-dependent code**:
  ```powerquery
  check = Text.StartsWith(trim, "#", Comparer.Ordinal)  // May fail depending on Power Query version
  ```
  
  **Portable code**:
  ```powerquery
  check = Text.StartsWith(trim, "#")  // Works across all versions
  ```
  
- **Solution**: Omit the comparer parameter from `Text.StartsWith` calls to ensure cross-version compatibility. For case-insensitive checks, use `Text.Upper()` or `Text.Lower()` preprocessing instead.
  
- **Prevention**:
  - Favor 2-parameter form of `Text.StartsWith(text, substring)` for maximum compatibility
  - If case-insensitive matching needed, normalize text case BEFORE calling Text.StartsWith
  - Example: `Text.StartsWith(Text.Upper(value), Text.Upper(prefix))`
  - Document any version-dependent behavior discovered during testing

### Issue: Text.Contains Comparer Parameter May Not Be Needed
- **Date**: 2026-02-09
- **Function(s)**: TestWebAimContrast
- **Category**: Code Simplification
- **Severity**: Low
- **Problem**: Used `Text.Contains(Concat, "Test Failures", Comparer.Ordinal)` when checking for a known string literal that appears verbatim. Since "Test Failures" is an exact string created by the function itself, case-insensitive comparison is unnecessary.
  
- **Solution**: Simplified to `Text.Contains(Concat, "Test Failures")` for readability and to avoid potential version compatibility issues.
  
- **Prevention**: Only use comparer parameters when actually needed for user input or external data. For internal string literals created by the function, simple comparison is sufficient.

---

## Summary: PQLint Culture/Comparer Recommendations Require Validation

**Key Lesson**: PQLint's recommendations for adding culture and comparer parameters are beneficial for internationalization BUT must be validated against actual Power Query function signatures before implementation.

**Affected Functions with Parameter Signature Restrictions**:
- ❌ `Text.AfterDelimiter` - NO comparer parameter (3 params max)
- ❌ `Text.Replace` - NO comparer parameter (3 params max)
- ⚠️ `Text.StartsWith` - Comparer support varies by version
- ⚠️ `Text.Contains` - Comparer exists but may not be needed
- ❌ `List.PositionOf` - Cannot use BOTH occurrence AND comparer (choose one)

**Best Practice**:
1. Review PQLint suggestions critically
2. Check Microsoft Learn documentation for function signatures
3. Test code with new parameters before committing
4. Prefer simplicity when additional parameters don't add value
5. Document false positives in this file to prevent future errors

---

## Last Updated
This document was created on 2026-02-07 and updated on 2026-02-09 throughout the migration process.

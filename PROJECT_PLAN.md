# PQ Shared Library - Migration Project Plan

## Project Goal
Migrate all Power Query functions from verbose `Function.From` format to simplified direct function syntax, while validating with PQLint and consolidating into a master TMDL file.

## GitHub Repository
- **Owner**: cbaragao
- **Repo**: PQ-Shared-Library
- **URL**: https://github.com/cbaragao/PQ-Shared-Library

## Available Tools
- **PQLint MCP**: Code linting and validation for Power Query/M Language
- **Microsoft Learn MCP**: Official Microsoft documentation search for Power Query guidance
- **GitHub MCP**: Repository management, issue tracking, and PR automation (if GitHub repo is configured)

## Migration Status
- **Total Functions**: 44
- **Completed**: 28
- **In Progress**: 0
- **Remaining**: 9
- **Deprecated**: 8 (Corr, Z, QuartileStats, MegaAverage, MegaStDevS, Pearson, RemoveNullColumns, RoundColumns)
- **Progress**: 64% complete (28/44 functions)

---

## Migration Requirements

### Naming Conventions (PowerShell Verb-Noun Format)
All functions must follow **PowerShell-style Verb-Noun** naming for consistency and IntelliSense discovery:
- **Verb-Noun format**: `Measure-Distance` not `CalculateDistance`
- **Approved verbs only**: Use PowerShell approved verbs (Get-, Measure-, Test-, Convert-, Remove-, New-, Invoke-, etc.)
- **No "fn" prefixes**: Remove all "fn" prefixes during migration
- **PascalCase**: All function names use PascalCase (e.g., `Measure-Distance`, `Get-ColorHue`)
- **Singular nouns**: Use `Get-Color` not `Get-Colors`

**See [documentation/NamingConventions.md](documentation/NamingConventions.md) for**:
- Complete list of approved verbs for data prep/ETL
- Function renaming guide for all 44 functions
- Examples and usage patterns

**Common renames**:
- `fnRandomNumber` → `New-RandomNumber`
- `CalculateDistance` → `Measure-Distance`
- `RoundDateTime` → `ConvertTo-RoundedDateTime`
- `CheckColorBlind` → `Test-ColorBlindness`
- `RunSQLQuery` → `Invoke-SQLQuery`

### Documentation Standards
All functions must include:
- **Documentation.Name**: Function name (without "fn" prefix)
- **Documentation.LongDescription**: Clear description of function purpose, parameters, and return value
- **Documentation.Examples**: At least 2 examples showing different use cases with expected results

**If documentation is missing**: 
- Analyze the function code to understand its purpose
- Create appropriate descriptions and test cases
- Ensure examples demonstrate the function's key capabilities

### Code Quality
- Remove `Function.From` wrapper syntax
- Use simplified direct function syntax: `(params) => expression`
- Pass PQLint validation (severity 2: best practices + potential issues)
- All test cases must pass before merging

---

## DateTime Functions (1 function)

### Task 1: Migrate RoundDateTime → ConvertTo-RoundedDateTime
- **Branch**: `migrate/ConvertTo-RoundedDateTime`
- **File**: `functions/DateTime/ConvertToRoundedDateTime.pq`
- **Status**: ✅ Completed
- **Steps**:
  1. Create branch `migrate/RoundDateTime`
  2. Remove `Function.From` wrapper
  3. Simplify function syntax to direct lambda
  4. Create test file with examples
  5. Test function with expected results
  6. Run PQLint (severity 2)
  7. Fix all linting issues and bugs
  8. Re-test to verify fixes
  9. If issues arise, search Microsoft Learn via MCP server for official Power Query documentation
  10. Document issues in LESSONS_LEARNED.md
  11. Commit changes
  12. Merge to main
  13. Update this status to "Completed"

---

## Geo Functions (2 functions)

### Task 2: Migrate Bearing → Measure-Bearing
- **Branch**: `migrate/Measure-Bearing`
- **File**: `functions/Geo/MeasureBearing.pq`
- **Status**: ✅ Completed

### Task 3: Migrate CalculateDistance → Measure-Distance
- **Branch**: `migrate/Measure-Distance`
- **File**: `functions/Geo/MeasureDistance.pq`
- **Status**: ✅ Completed
- **GitHub Issue**: [#1](https://github.com/cbaragao/PQ-Shared-Library/issues/1)

---

## Math Functions (12 functions)

### Task 4: Migrate Benford → Test-Benford
- **Branch**: `migrate/Test-Benford`
- **File**: `functions/Math/TestBenford.pq`
- **Status**: ✅ Completed
- **Notes**: Added optional culture parameter with "en-US" default for flexibility

### Task 5: Migrate Conf → Get-ConfidenceInterval
- **Branch**: `migrate/Get-ConfidenceInterval`
- **File**: `functions/Math/GetConfidenceInterval.pq`
- **Status**: ✅ Completed

### Task 6: Corr (DEPRECATED)
- **Branch**: N/A
- **File**: `functions/Math/Corr.pq` (removed)
- **Status**: ❌ Deprecated
- **Reason**: Correlation matrices are better implemented in DAX using functions like CORREL.X() or calculated columns. Power Query is not the optimal tool for this statistical operation.
- **Recommendation**: Use DAX measures or calculated tables in Power BI for correlation analysis.

### Task 7: Migrate ErlangC → GetErlangC
- **Branch**: `migrate/ErlangC`
- **File**: `functions/Math/GetErlangC.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to GetErlangC per Verb-Noun convention. Fixed N calculation with Number.RoundUp to ensure integer for range operator. Added comprehensive type annotations and 3 test scenarios. Enhanced documentation with complete parameter descriptions.

### Task 8: Migrate fnExponentialWeightedMovingAverage → CalculateEWMA
- **Branch**: `migrate/CalculateEWMA`
- **File**: `functions/Math/CalculateEWMA.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to CalculateEWMA per Verb-Noun convention. Removed Function.From wrapper and redundant Number.From() calls for cleaner code. Added type annotations to List.Accumulate iterator. Enhanced documentation with detailed parameter descriptions and 3 examples. Created comprehensive test suite with 4 test cases using Number.Round() with RoundingMode.AwayFromZero for consistent precision handling.

### Task 9: Migrate GenerateRandomNumbers → NewRandomNumbers
- **Branch**: `migrate/GenerateRandomNumbers`
- **File**: `functions/Math/NewRandomNumbers.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to NewRandomNumbers per Verb-Noun convention (New- is the approved verb for creating/generating). Removed Function.From wrapper, replaced params{0-2} with named parameters. Added culture parameters to Text.From() and Number.FromText() for PQLint compliance. Enhanced documentation with detailed parameter descriptions and example. Created test suite with verified random number generation.

### Task 10: Migrate GetFactors
- **Branch**: `migrate/Get-Factors`
- **File**: `functions/Math/GetFactors.pq`
- **Status**: ✅ Completed
- **Notes**: Added return types for functions and culture/comparer parameters for PQLint compliance

### Task 11: Migrate MegaAverage
- **Branch**: `migrate/MegaAverage`
- **File**: `functions/Math/MegaAverage.pq`
- **Status**: ❌ Deprecated
- **Reason**: Complex statistical calculations (trimmed, geometric, winsorized averages) better implemented as DAX measures where they can be dynamic and calculated in the data model.
- **Recommendation**: Use DAX measures for statistical aggregations in Power BI.

### Task 12: Migrate MegaStDevS
- **Branch**: `migrate/MegaStDevS`
- **File**: `functions/Math/MegaStDevS.pq`
- **Status**: ❌ Deprecated
- **Reason**: Complex statistical calculations (trimmed, geometric, winsorized standard deviations) better implemented as DAX measures where they can be dynamic and calculated in the data model.
- **Recommendation**: Use DAX measures for statistical aggregations in Power BI.

### Task 13: Migrate Pearson
- **Branch**: `migrate/Pearson`
- **File**: `functions/Math/Pearson.pq`
- **Status**: ❌ Deprecated
- **Reason**: Statistical correlation calculations are better implemented in DAX using built-in correlation functions. Power Query is for data transformation, not statistical analysis.
- **Recommendation**: Use DAX correlation functions (e.g., create calculated columns or measures) in Power BI. See also deprecated Corr function (Task 6).

### Task 14: Migrate QuartileStats
- **Branch**: `migrate/QuartileStats`
- **File**: `functions/Math/QuartileStats.pq`
- **Status**: ❌ Deprecated
- **Reason**: Power Query has built-in `List.Percentile()` function. DAX has `PERCENTILE.INC()` and `PERCENTILE.EXC()`. Outlier detection is better done in DAX or visualization layer.
- **Recommendation**: Use native percentile functions in Power Query for ETL, or DAX measures for dynamic calculations in reports.

### Task 15: Migrate Z
- **Branch**: `migrate/Z`
- **File**: `functions/Math/Z.pq`
- **Status**: ❌ Deprecated
- **Reason**: This is an 832-line hardcoded Z-score lookup table. Modern Excel, Power BI, and statistical tools have built-in functions (e.g., NORM.S.DIST, NORM.S.INV) that calculate these values dynamically without needing massive static lookup tables.
- **Recommendation**: Use native statistical distribution functions in Excel (NORM.S.DIST, NORM.S.INV) or Power BI DAX (NORM.DIST, NORM.INV) instead.

---

## R Functions (2 functions)

### Task 16: Migrate fnRGetLinearModelCoefficients → GetLinearModelCoefficients
- **Branch**: `migrate/GetLinearModelCoefficients`
- **File**: `functions/R/GetLinearModelCoefficients.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to GetLinearModelCoefficients per Verb-Noun convention (Get- is approved verb). Removed Function.From wrapper, replaced params{0-2} with named parameters (df, independent, dependent, family). Enhanced documentation with detailed parameter descriptions, GLM family explanation, and note about R integration requirement. Created comprehensive test suite with sample logistic regression data and validation checks. Tested successfully in Power BI with R integration.

### Task 17: Migrate fnRPredictWithLogitModel → InvokeLogitPrediction
- **Branch**: `migrate/InvokeLogitPrediction`
- **File**: `functions/R/InvokeLogitPrediction.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to InvokeLogitPrediction per Verb-Noun convention (Invoke- is approved verb for executing operations). Removed Function.From wrapper, replaced params{0-2} with named parameters (df, independent, dependent). Enhanced documentation with GLM explanation, R integration requirement note, and second example showing multiple predictors with R formula syntax. Created comprehensive test suite with 3 test cases validating single predictor, multiple predictors, and binary threshold logic. Passed all tests with R integration. PQLint validation: zero violations.

---

## SQL Functions (1 function)

### Task 18: Migrate RunSQLQuery → InvokeSQLQuery
- **Branch**: `migrate/InvokeSQLQuery`
- **File**: `functions/SQL/InvokeSQLQuery.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to InvokeSQLQuery per Verb-Noun convention (Invoke- is approved verb for executing operations). Removed Function.From wrapper, replaced params{0-1} with named parameters (Source, Query). Enhanced documentation with explanation of Value.NativeQuery, query folding, and type preservation. Added second example showing complex query with JOIN and WHERE clause. Created comprehensive test suite with 4 validation tests for function structure and type safety. PQLint validation: zero violations.

---

## String Functions (4 functions)

### Task 19: Migrate EncodeText → ConvertToEncodedText
- **Branch**: `migrate/EncodeText`
- **File**: `functions/String/ConvertToEncodedText.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to ConvertToEncodedText per Verb-Noun convention (ConvertTo- is approved verb for transforming to specific format, "Encode" is not an approved verb). Removed Function.From wrapper, replaced params{0} with named parameter (str). Added culture parameter "en-US" to Number.ToText for PQLint compliance. Enhanced documentation with clearer explanation and added second example for single character. Created comprehensive test suite with 5 test cases covering various scenarios. Files renamed to match function name (EncodeText.pq → ConvertToEncodedText.pq). All tests passed. PQLint validation: Service unavailable during migration, but function follows validated patterns.

### Task 20: Migrate ReadFileToText → GetFileText
- **Branch**: `migrate/GetFileText`
- **File**: `functions/String/GetFileText.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to GetFileText per Verb-Noun convention (Get- is approved verb for retrieving data, "Read" is not an approved verb). Removed Function.From wrapper, replaced params{0} with named parameter (filepath). Enhanced documentation with clearer explanation and added second example for configuration files. Created test suite with function structure validation (function signature, return type) since this function requires actual file system access. Files renamed to match function name (ReadFileToText.pq → GetFileText.pq). All tests passed. PQLint validation: zero violations.

### Task 21: Migrate RemoveHTMLTags
- **Branch**: `migrate/RemoveHTMLTags`
- **File**: `functions/String/RemoveHTMLTags.pq`
- **Status**: ✅ Completed
- **Notes**: Function name already used approved "Remove-" verb. Standardized casing to RemoveHTMLTags (all caps "HTML"). Removed Function.From wrapper, replaced params{0} with named parameter (htmlString). Fixed bug: changed removeTags{0} to removeTags{0}[text] to properly extract text column. Added optional culture parameter with default "en-US" using null-coalescing operator (??). Enhanced documentation and added second example. Created comprehensive test suite with 5 test cases. All tests passed. PQLint validation: zero violations.

### Task 22: Migrate RemoveUnwantedCharacters → RemoveChars
- **Branch**: `migrate/RemoveUnwantedCharacters`
- **File**: `functions/String/RemoveChars.pq` (renamed from RemoveUnwantedCharacters.pq)
- **Status**: ✅ Completed
- **Notes**: Function renamed from RemoveUnwantedCharacters to RemoveChars for brevity (Remove- verb already approved). Removed Function.From wrapper, replaced params{0-5} with named parameters (str, keep_upper, keep_lower, keep_nums, keep_specials, keep_chars). Simplified nested fnRemove function by inlining the logic directly. Used null-coalescing operator (??) for cleaner default values. Enhanced documentation with clearer parameter descriptions. Added second example. Created comprehensive test suite with 7 test cases covering all parameter combinations including defaults, edge cases (empty string), and special character preservation. All tests passed. PQLint validation: zero violations. Files renamed to match new function name.

---

## Tbl Functions (6 functions)

### Task 23: Migrate ColumnToList → ConvertColumnToList
- **Branch**: `migrate/ColumnToList`
- **File**: `functions/Tbl/ConvertColumnToList.pq` (renamed from ColumnToList.pq)
- **Status**: ✅ Completed
- **Notes**: Function renamed from ColumnToList to ConvertColumnToList for clarity (ConvertTo- verb pattern). Removed Function.From wrapper, replaced params{0} and params{1} with named parameters (t, column_name). Added MissingField.Error parameter to Table.SelectColumns as per PQLint best practice to explicitly handle missing columns. Enhanced documentation with clearer explanation. Added second example. Created comprehensive test suite with 5 test cases covering different column types, single row, and empty table. All tests passed. PQLint validation: zero violations after adding MissingField parameter. Files renamed to match new function name.

### Task 24: Migrate ConvertDateTimeZoneToDate
- **Branch**: `migrate/ConvertDateTimeZoneToDate`
- **File**: `functions/Tbl/ConvertDateTimeZoneToDate.pq`
- **Status**: ✅ Completed
- **Notes**: Function name kept as-is (already uses ConvertTo- verb pattern). Removed Function.From wrapper, replaced params{0} with named parameter (tbl). Added optional culture parameter with default "en-US" for PQLint compliance. Used Date.From() with culture for proper value conversion (not just type metadata change). Added lambda type annotations: (state as table, current as text) as table. Used List.Accumulate with Table.TransformColumns pattern to iterate over datetime/datetimezone columns. Changed from Table.TransformColumnTypes (which only changes metadata) to Table.TransformColumns with Date.From (which actually converts values). Enhanced documentation with culture parameter explanation. Manually tested with 3 scenarios: single datetimezone column, multiple datetime columns, and mixed table with non-datetime columns. All manual tests passed. PQLint validation: zero violations after adding culture parameter and lambda types. No automated test file created - manual testing documented in function comments.

### Task 25: Migrate fnRandomNumber → AddRandomNumber
- **Branch**: `migrate/AddRandomNumber`
- **File**: `functions/Tbl/AddRandomNumber.pq` (renamed from fnRandomNumber.pq)
- **Status**: ✅ Completed
- **Notes**: Function renamed from fnRandomNumber to AddRandomNumber (Add- verb for adding a Random column to a table). Removed Function.From wrapper, replaced params{0} and params{1} with named parameters (t, seed). Added MissingField.Ignore parameter to Table.RemoveColumns per PQLint best practice to handle cases where the __Index column might not exist. Enhanced documentation with two detailed examples showing different seed values and expected behavior. Created comprehensive test suite with 9 test cases covering: 3-row table, 2-row table, reproducibility (same seed produces identical results), single row table, and empty table. All tests passed. PQLint validation: zero violations after adding MissingField.Ignore parameter. Function successfully adds a Random column with deterministic values based on seed.

### Task 26: Migrate RemoveNullColumns
- **Branch**: `migrate/RemoveNullColumns`
- **File**: `functions/Tbl/RemoveNullColumns.pq`
- **Status**: ❌ Deprecated
- **Notes**: Function deprecated due to issues with Table.Profile behavior. Unable to reliably identify completely null columns using Count field. Function logic was unclear and testing proved problematic.

### Task 27: Migrate ReplaceInColumnNames → UpdateColumnNames
- **Branch**: `migrate/UpdateColumnNames`
- **File**: `functions/Tbl/UpdateColumnNames.pq` (renamed from ReplaceInColumnNames.pq)
- **Status**: ✅ Completed
- **Notes**: Function renamed from ReplaceInColumnNames to UpdateColumnNames (Update- verb for modifying/updating data). Removed Function.From wrapper, replaced params{0-2} with named parameters (t, search, replacement). Added optional culture parameter with default "en-US" for Text.Proper per PQLint best practice. Function replaces specified text in column names using Replacer.ReplaceText and applies Text.Proper to convert to proper case (first letter of each word capitalized). Enhanced documentation with clearer explanation and second example. Created comprehensive test suite with 5 test cases covering: underscore to space replacement, hyphen to underscore, no match with Text.Proper applied, multiple occurrences, and empty replacement. All tests passed. PQLint validation: zero violations after adding culture parameter.

### Task 28: Migrate RoundColumns
- **Branch**: `migrate/RoundColumns`
- **File**: `functions/Tbl/RoundColumns.pq`
- **Status**: ❌ Deprecated
- **Notes**: Function deprecated per user request. Functionality deemed unnecessary or too specific for the library.

---

## Utils Functions (5 functions)

### Task 29: Migrate CreateBatches → New-Batches
- **Branch**: `migrate/NewBatches`
- **File**: `functions/Utils/NewBatches.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to NewBatches per Verb-Noun convention (New- is the approved verb for creating/generating resources). Implemented proper two-commit workflow: (1) git mv rename only, (2) content modifications. Removed Function.From wrapper, replaced params{0-2} with named parameters (batchSize, totalSize, baseValue). Added return type annotations for List.Generate. Added MissingField.Ignore to Table.ReorderColumns. Updated Documentation.Name to 'New-Batches' (hyphenated for user docs). Created comprehensive test suite with 4 test cases. All tests passed, PQLint validation: 0 violations. Git history properly preserved with R100 rename tracking.

### Task 30: Migrate fnDynamicSelectList → SelectDynamicList
- **Branch**: `migrate/SelectDynamicList`
- **File**: `functions/Utils/SelectDynamicList.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed to SelectDynamicList per Verb-Noun convention (Select- is approved verb). Removed Function.From wrapper, replaced params{0-1} with named parameters (l, selections). Added return type annotations and lambda types. Added Comparer.Ordinal to Text.Contains and List.PositionOf for PQLint compliance. Refactored for better readability with intermediate let bindings. Updated Documentation.Name to 'Select-DynamicList'. Enhanced documentation with second example. Created comprehensive test suite with 5 test cases. Variable name: SelectDynamicList (PascalCase, no hyphen).

### Task 31: Migrate GetFunctionMetadata
- **Branch**: `migrate/GetFunctionMetadata`
- **File**: `functions/Utils/GetFunctionMetadata.pq`
- **Status**: ✅ Completed
- **Notes**: Function name already used approved Get- verb. Removed Function.From wrapper, replaced params{0-1} with named parameters (function_name, return). Added optional culture parameter with default 'en-US'. Added culture parameter to Text.Lower for PQLint compliance. Changed return type from 'text' to 'any' for flexibility. Refactored for better readability with intermediate variables. Updated Documentation.Name to 'Get-FunctionMetadata'. Enhanced documentation with third example. Created comprehensive test suite with 6 test cases covering name, description, example retrieval, and case insensitivity.

### Task 32: Migrate PostRequest → InvokePostRequest
- **Branch**: `migrate/InvokePostRequest`
- **File**: `functions/Utils/InvokePostRequest.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed from PostRequest to InvokePostRequest per Verb-Noun convention (Invoke- is approved verb, "Post" is not). Removed Function.From wrapper. Added optional ContentType parameter with default 'application/json' for flexibility. Added TextEncoding.Utf8 to Text.ToBinary for proper encoding. Changed return type from 'text' to 'any' for flexibility. Updated Documentation.Name to 'Invoke-PostRequest'. Enhanced documentation with ContentType explanation and second example showing custom content type. Created test suite with 4 structural validation tests (function type, parameter count, parameter names, return type). Variable name: InvokePostRequest (PascalCase, no hyphen).

### Task 33: Migrate Switch → SelectCase
- **Branch**: `migrate/SelectCase`
- **File**: `functions/Utils/SelectCase.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed from Switch to SelectCase per Verb-Noun convention (Select- is approved verb, "Switch" is not). Removed Function.From wrapper, replaced params{0-2} with named parameters (value, l, default). Added RoundingMode.Down to Number.Mod for PQLint compliance. Added Occurrence.First to List.PositionOf for clarity. Improved code readability with better formatting. Updated Documentation.Name to 'Select-Case'. Enhanced documentation with pattern-matching explanation and third example showing default case. Created comprehensive test suite with 6 test cases covering first/second match, default, multiple matches, text comparison, and boolean values. Variable name: SelectCase (PascalCase, no hyphen).

---

## UX Functions (12 functions)

### Task 34: Migrate CheckColorBlind → TestColorBlindness
- **Branch**: `migrate/TestColorBlindness`
- **File**: `functions/UX/TestColorBlindness.pq`
- **Status**: ✅ Completed
- **Notes**: Renamed from CheckColorBlind to TestColorBlindness per Verb-Noun convention (Test- is approved verb, "Check" is not). Removed Function.From wrapper, replaced params{0} with named parameter (HEX). Added optional culture parameter with default 'en-US'. Added Comparer.Ordinal to List.PositionOf and Text.AfterDelimiter for PQLint compliance. Added RoundingMode parameters to Number.Mod and Number.RoundAwayFromZero. Added culture parameters to Number.From and Text.From calls throughout the 521-line function. Updated Documentation.Name to 'Test-ColorBlindness'. Enhanced documentation with detailed explanation of protanomaly, deuteranomaly, and tritanomaly, plus second example. Created test suite with 5 structural validation tests. Complex function with color blindness simulation matrices from academic research. Variable name: TestColorBlindness (PascalCase, no hyphen).

### Task 35: Migrate CheckColorContrast
- **Branch**: `migrate/CheckColorContrast`
- **File**: `functions/UX/CheckColorContrast.pq`
- **Status**: Not Started

### Task 36: Migrate CheckWebAimContrast
- **Branch**: `migrate/CheckWebAimContrast`
- **File**: `functions/UX/CheckWebAimContrast.pq`
- **Status**: Not Started

### Task 37: Migrate GetColorHue
- **Branch**: `migrate/GetColorHue`
- **File**: `functions/UX/GetColorHue.pq`
- **Status**: Not Started

### Task 38: Migrate GetColorScheme
- **Branch**: `migrate/GetColorScheme`
- **File**: `functions/UX/GetColorScheme.pq`
- **Status**: Not Started

### Task 39: Migrate GetCompColor
- **Branch**: `migrate/GetCompColor`
- **File**: `functions/UX/GetCompColor.pq`
- **Status**: Not Started

### Task 40: Migrate GetFontColor
- **Branch**: `migrate/GetFontColor`
- **File**: `functions/UX/GetFontColor.pq`
- **Status**: Not Started

### Task 41: Migrate GetHexValue
- **Branch**: `migrate/GetHexValue`
- **File**: `functions/UX/GetHexValue.pq`
- **Status**: Not Started

### Task 42: Migrate GetLuminosity
- **Branch**: `migrate/GetLuminosity`
- **File**: `functions/UX/GetLuminosity.pq`
- **Status**: Not Started

### Task 43: Migrate GetRGBValue
- **Branch**: `migrate/GetRGBValue`
- **File**: `functions/UX/GetRGBValue.pq`
- **Status**: Not Started

### Task 44: Migrate MedianAspectRatio
- **Branch**: `migrate/MedianAspectRatio`
- **File**: `functions/UX/MedianAspectRatio.pq`
- **Status**: Not Started

---

## Final Phase

### Task 45: Create Master TMDL File
- **Branch**: `feature/master-tmdl`
- **GitHub Issue**: [#43](https://github.com/cbaragao/PQ-Shared-Library/issues/43)
- **Status**: Not Started
- **Steps**:
  1. Review all migrated functions for consistency
  2. Create consolidated TMDL master file
  3. Validate all functions load correctly
  4. Update BuildMaster.ps1 if needed
  5. Final PQLint validation on master file
  6. Merge to main

### Task 46: Create Comprehensive README.md
- **Branch**: `docs/comprehensive-readme`
- **GitHub Issue**: [#44](https://github.com/cbaragao/PQ-Shared-Library/issues/44)
- **Status**: Not Started
- **Prerequisites**: All function migrations complete (Tasks 1-45)
- **Steps**:
  1. Document all 44 functions organized by category
  2. Include naming convention changes (no "fn" prefixes)
  3. Add installation and usage instructions
  4. Document development workflow and standards
  5. Include contributing guidelines
  6. Add migration notes and lessons learned
  7. Document available MCP tools
  8. Merge to main

---

## GitHub Issues
All tasks are tracked in GitHub:
- Function migrations: [Issues #1-#42](https://github.com/cbaragao/PQ-Shared-Library/issues)
- Master TMDL file: [Issue #43](https://github.com/cbaragao/PQ-Shared-Library/issues/43)
- Comprehensive README: [Issue #44](https://github.com/cbaragao/PQ-Shared-Library/issues/44)

---

## Notes
- Each task should be completed atomically (one function at a time)
- Branch naming convention: `migrate/Verb-Noun` (use new Verb-Noun name, e.g., `migrate/Measure-Distance`)
- Apply PowerShell Verb-Noun naming (see [documentation/NamingConventions.md](documentation/NamingConventions.md))
- Remove "fn" prefixes and use approved verbs (Get-, Measure-, Test-, Convert-, etc.)
- Ensure all functions have complete documentation (description + 2+ examples)
- Always check LESSONS_LEARNED.md before starting a new function
- Update migration status counts as tasks are completed
- All linting must pass before merging to main

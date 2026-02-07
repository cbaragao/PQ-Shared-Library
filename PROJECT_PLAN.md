# PQ Shared Library - Migration Project Plan

## Project Goal
Migrate all Power Query functions from verbose `Function.From` format to simplified direct function syntax, while validating with PQLint and consolidating into a master TMDL file.

## Migration Status
- **Total Functions**: 45
- **Completed**: 2
- **In Progress**: 0
- **Remaining**: 43

---

## DateTime Functions (1 function)

### Task 1: Migrate RoundDateTime
- **Branch**: `migrate/RoundDateTime`
- **File**: `functions/DateTime/RoundDateTime.pq`
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

### Task 2: Migrate Bearing
- **Branch**: `migrate/Bearing`
- **File**: `functions/Geo/Bearing.pq`
- **Status**: ✅ Completed

### Task 3: Migrate CalculateDistance
- **Branch**: `migrate/CalculateDistance`
- **File**: `functions/Geo/CalculateDistance.pq`
- **Status**: Not Started

---

## Math Functions (12 functions)

### Task 4: Migrate Benford
- **Branch**: `migrate/Benford`
- **File**: `functions/Math/Benford.pq`
- **Status**: Not Started

### Task 5: Migrate Conf
- **Branch**: `migrate/Conf`
- **File**: `functions/Math/Conf.pq`
- **Status**: Not Started

### Task 6: Migrate Corr
- **Branch**: `migrate/Corr`
- **File**: `functions/Math/Corr.pq`
- **Status**: Not Started

### Task 7: Migrate ErlangC
- **Branch**: `migrate/ErlangC`
- **File**: `functions/Math/ErlangC.pq`
- **Status**: Not Started

### Task 8: Migrate fnExponentialWeightedMovingAverage
- **Branch**: `migrate/fnExponentialWeightedMovingAverage`
- **File**: `functions/Math/fnExponentialWeightedMovingAverage.pq`
- **Status**: Not Started

### Task 9: Migrate GenerateRandomNumbers
- **Branch**: `migrate/GenerateRandomNumbers`
- **File**: `functions/Math/GenerateRandomNumbers.pq`
- **Status**: Not Started

### Task 10: Migrate GetFactors
- **Branch**: `migrate/GetFactors`
- **File**: `functions/Math/GetFactors.pq`
- **Status**: Not Started

### Task 11: Migrate MegaAverage
- **Branch**: `migrate/MegaAverage`
- **File**: `functions/Math/MegaAverage.pq`
- **Status**: Not Started

### Task 12: Migrate MegaStDevS
- **Branch**: `migrate/MegaStDevS`
- **File**: `functions/Math/MegaStDevS.pq`
- **Status**: Not Started

### Task 13: Migrate Pearson
- **Branch**: `migrate/Pearson`
- **File**: `functions/Math/Pearson.pq`
- **Status**: Not Started

### Task 14: Migrate QuartileStats
- **Branch**: `migrate/QuartileStats`
- **File**: `functions/Math/QuartileStats.pq`
- **Status**: Not Started

### Task 15: Migrate Z
- **Branch**: `migrate/Z`
- **File**: `functions/Math/Z.pq`
- **Status**: Not Started

---

## R Functions (2 functions)

### Task 16: Migrate fnRGetLinearModelCoefficients
- **Branch**: `migrate/fnRGetLinearModelCoefficients`
- **File**: `functions/R/fnRGetLinearModelCoefficients.pq`
- **Status**: Not Started

### Task 17: Migrate fnRPredictWithLogitModel
- **Branch**: `migrate/fnRPredictWithLogitModel`
- **File**: `functions/R/fnRPredictWithLogitModel.pq`
- **Status**: Not Started

---

## SQL Functions (1 function)

### Task 18: Migrate RunSQLQuery
- **Branch**: `migrate/RunSQLQuery`
- **File**: `functions/SQL/RunSQLQuery.pq`
- **Status**: Not Started

---

## String Functions (4 functions)

### Task 19: Migrate EncodeText
- **Branch**: `migrate/EncodeText`
- **File**: `functions/String/EncodeText.pq`
- **Status**: Not Started

### Task 20: Migrate ReadFileToText
- **Branch**: `migrate/ReadFileToText`
- **File**: `functions/String/ReadFileToText.pq`
- **Status**: Not Started

### Task 21: Migrate RemoveHTMLTags
- **Branch**: `migrate/RemoveHTMLTags`
- **File**: `functions/String/RemoveHTMLTags.pq`
- **Status**: Not Started

### Task 22: Migrate RemoveUnwantedCharacters
- **Branch**: `migrate/RemoveUnwantedCharacters`
- **File**: `functions/String/RemoveUnwantedCharacters.pq`
- **Status**: Not Started

---

## Tbl Functions (6 functions)

### Task 23: Migrate ColumnToList
- **Branch**: `migrate/ColumnToList`
- **File**: `functions/Tbl/ColumnToList.pq`
- **Status**: Not Started

### Task 24: Migrate ConvertDateTimeZoneToDate
- **Branch**: `migrate/ConvertDateTimeZoneToDate`
- **File**: `functions/Tbl/ConvertDateTimeZoneToDate.pq`
- **Status**: Not Started

### Task 25: Migrate fnRandomNumber
- **Branch**: `migrate/fnRandomNumber`
- **File**: `functions/Tbl/fnRandomNumber.pq`
- **Status**: Not Started

### Task 26: Migrate RemoveNullColumns
- **Branch**: `migrate/RemoveNullColumns`
- **File**: `functions/Tbl/RemoveNullColumns.pq`
- **Status**: Not Started

### Task 27: Migrate ReplaceInColumnNames
- **Branch**: `migrate/ReplaceInColumnNames`
- **File**: `functions/Tbl/ReplaceInColumnNames.pq`
- **Status**: Not Started

### Task 28: Migrate RoundColumns
- **Branch**: `migrate/RoundColumns`
- **File**: `functions/Tbl/RoundColumns.pq`
- **Status**: Not Started

---

## Utils Functions (5 functions)

### Task 29: Migrate CreateBatches
- **Branch**: `migrate/CreateBatches`
- **File**: `functions/Utils/CreateBatches.pq`
- **Status**: Not Started

### Task 30: Migrate fnDynamicSelectList
- **Branch**: `migrate/fnDynamicSelectList`
- **File**: `functions/Utils/fnDynamicSelectList.pq`
- **Status**: Not Started

### Task 31: Migrate GetFunctionMetadata
- **Branch**: `migrate/GetFunctionMetadata`
- **File**: `functions/Utils/GetFunctionMetadata.pq`
- **Status**: Not Started

### Task 32: Migrate PostRequest
- **Branch**: `migrate/PostRequest`
- **File**: `functions/Utils/PostRequest.pq`
- **Status**: Not Started

### Task 33: Migrate Switch
- **Branch**: `migrate/Switch`
- **File**: `functions/Utils/Switch.pq`
- **Status**: Not Started

---

## UX Functions (12 functions)

### Task 34: Migrate CheckColorBlind
- **Branch**: `migrate/CheckColorBlind`
- **File**: `functions/UX/CheckColorBlind.pq`
- **Status**: Not Started

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
- **Status**: Not Started
- **Steps**:
  1. Review all migrated functions
  2. Create consolidated TMDL master file
  3. Validate all functions load correctly
  4. Update BuildMaster.ps1 if needed
  5. Final PQLint validation on master file
  6. Update README.md with new structure
  7. Merge to main

---

## Notes
- Each task should be completed atomically (one function at a time)
- Branch naming convention: `migrate/FunctionName`
- Always check LESSONS_LEARNED.md before starting a new function
- Update migration status counts as tasks are completed
- All linting must pass before merging to main

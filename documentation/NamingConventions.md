# Power Query Function Naming Conventions

## Verb-Noun Format

All functions follow PowerShell-style **Verb-Noun** naming to ensure consistency and IntelliSense-friendly discovery.

**⚠️ IMPORTANT - M Language Identifier Constraints:**
- **M Language identifiers cannot contain hyphens** (e.g., `Get-Factors` is invalid)
- Use **PascalCase without hyphens** for actual function names: `GetFactors`, `MeasureDistance`, `TestBenford`
- The "Verb-Noun" concept guides name selection (use approved verbs + descriptive nouns)
- In practice, concatenate Verb+Noun with no separator: `GetFactors`, `ConvertToRoundedDateTime`
- Documentation should show the actual identifier users will call: `GetFactors(28)` not `Get-Factors(28)`

## Approved Verbs for Data Prep & ETL

Based on PowerShell's approved verb list, these are the most relevant verbs for Power Query data preparation and ETL operations:

### Common Verbs (Generic Actions)
- **Get-**: Retrieve data, information, or calculate values (e.g., `Get-Distance`, `Get-ColorHue`)
- **Set-**: Modify or replace existing data (e.g., `Set-ColumnNames`)
- **Add-**: Append data to a collection or container (e.g., `Add-Column`)
- **Remove-**: Delete data from a collection (e.g., `Remove-NullColumns`, `Remove-HTMLTags`)
- **Select-**: Filter or choose specific data (e.g., `Select-DynamicList`)
- **Format-**: Arrange data in specific layout (e.g., `Format-Text`)
- **Find-**: Search for specific data (e.g., `Find-Pattern`)
- **New-**: Create a new resource (e.g., `New-Batches`)
- **Clear-**: Remove all content but keep structure
- **Join-**: Combine multiple items into one
- **Split-**: Separate data into parts

### Data Verbs (Data Handling)
- **Convert-**: Transform data format/type bidirectionally (e.g., `Convert-DateTimeZone`)
- **ConvertTo-**: Transform to specific format (e.g., `ConvertTo-RoundedDateTime`)
- **ConvertFrom-**: Transform from specific format
- **Export-**: Output data to external format
- **Import-**: Input data from external format
- **Merge-**: Combine multiple datasets into one
- **Group-**: Organize data by categories
- **Update-**: Refresh or modify to current state
- **Sync-**: Ensure consistency between datasets
- **Edit-**: Modify content by adding/removing

### Diagnostic Verbs (Calculations & Testing)
- **Measure-**: Calculate statistics or metrics (e.g., `Measure-Distance`, `Measure-Bearing`, `Measure-AspectRatio`)
- **Test-**: Validate or check conditions (e.g., `Test-ColorBlind`, `Test-ColorContrast`)

### Other Verbs
- **Invoke-**: Execute an operation (e.g., `Invoke-SQLQuery`, `Invoke-Request`)

## Naming Rules

1. **Use Verb-Noun concept**: Combine approved verb + descriptive noun (e.g., `GetDistance`, `MeasureCorrelation`)
2. **NO hyphens in identifiers**: M Language does not support hyphens - use `GetFactors` not `Get-Factors`
3. **Use PascalCase concatenation**: `GetColorScheme`, `ConvertToRoundedDateTime`, `MeasureDistance`
4. **Use approved verbs only**: See the lists above for data prep/ETL verbs
5. **Use singular nouns**: `GetColor` not `GetColors` (even if it returns multiple values)
6. **Be specific but concise**: `GetFontColor` not `GetFontColorForBackground`
7. **Avoid synonyms**: Use `Remove-` concept consistently, not mixing with `Delete-` or `Clear-`

## Function Renaming Guide

**Note**: The arrows show the conceptual Verb-Noun pattern, but actual identifiers use PascalCase concatenation without hyphens.

### Current Functions → New Names (Actual Identifiers)

#### Geo Functions
- `Bearing` → `MeasureBearing` (calculates angular measurement)
- `CalculateDistance` → `MeasureDistance` (calculates distance metric)

#### DateTime Functions  
- `RoundDateTime` → `ConvertToRoundedDateTime` (transforms to rounded format)

#### Math Functions
- `Benford` → `TestBenford` (validates Benford's law)
- `Conf` → `GetConfidenceInterval` 
- `Corr` → `MeasureCorrelation`
- `ErlangC` → `GetErlangC`
- `ExponentialWeightedMovingAverage` → `MeasureEWMA` (or `MeasureExponentialMovingAverage`)
- `GenerateRandomNumbers` → `NewRandomNumbers`
- `GetFactors` → `GetFactors` ✓ (already correct)
- `MegaAverage` → `MeasureMegaAverage`
- `MegaStDevS` → `MeasureMegaStandardDeviation`
- `Pearson` → `MeasurePearson` (or `MeasurePearsonCorrelation`)
- `QuartileStats` → `GetQuartileStats`
- `Z` → `MeasureZScore`

#### R Functions
- `RGetLinearModelCoefficients` → `GetLinearModelCoefficients`
- `RPredictWithLogitModel` → `InvokeLogitPrediction`

#### SQL Functions
- `RunSQLQuery` → `InvokeSQLQuery`

#### String Functions
- `EncodeText` → `ConvertToEncodedText`
- `ReadFileToText` → `GetFileText`
- `RemoveHTMLTags` → `RemoveHTMLTags` ✓ (already correct)
- `RemoveUnwantedCharacters` → `RemoveUnwantedCharacters` ✓ (already correct)

#### Tbl Functions
- `ColumnToList` → `ConvertToList` (or `ConvertToColumnList`)
- `ConvertDateTimeZoneToDate` → `ConvertToDate` (or `ConvertDateTimeZone`)
- `RandomNumber` → `NewRandomNumber`
- `RemoveNullColumns` → `RemoveNullColumns` ✓ (already correct)
- `ReplaceInColumnNames` → `UpdateColumnNames` (or `SetColumnNames`)
- `RoundColumns` → `ConvertToRoundedColumns` (or `FormatColumns`)

#### Utils Functions
- `CreateBatches` → `NewBatches`
- `DynamicSelectList` → `SelectDynamicList`
- `GetFunctionMetadata` → `GetFunctionMetadata` ✓ (already correct)
- `PostRequest` → `InvokePostRequest`
- `Switch` → `UseSwitch` (special case - Switch is reserved in PowerShell)

#### UX Functions
- `CheckColorBlind` → `TestColorBlindness` (or `TestColorBlindSafety`)
- `CheckColorContrast` → `TestColorContrast`
- `CheckWebAimContrast` → `TestWebAimContrast`
- `GetColorHue` → `GetColorHue` ✓ (already correct)
- `GetColorScheme` → `GetColorScheme` ✓ (already correct)
- `GetCompColor` → `GetComplementaryColor`
- `GetFontColor` → `GetFontColor` ✓ (already correct)
- `GetHexValue` → `Get-HexValue` ✓ (already correct)
- `GetLuminosity` → `Get-Luminosity` ✓ (already correct)
- `GetRGBValue` → `Get-RGBValue` ✓ (already correct)
- `MedianAspectRatio` → `Measure-MedianAspectRatio`

## Benefits of Verb-Noun Naming

1. **IntelliSense grouping**: Functions group by verb prefix (all `Get*` together)
2. **Predictable**: Users know `Measure*` calculates, `Test*` validates
3. **Consistent**: Same verb prefix means same action across all functions
4. **Discoverable**: Easy to find related functions by filtering on verb prefix
5. **Professional**: Follows established PowerShell/industry conceptual standards

## Examples in Context

```powerquery
// Geographic calculations
MeasureDistance(lat1, lon1, lat2, lon2)
MeasureBearing(lat1, lon1, lat2, lon2)

// Data transformation
ConvertToRoundedDateTime(dateTime, precision)
ConvertToEncodedText(text, encoding)
ConvertDateTimeZone(table, column)

// Data cleaning
RemoveNullColumns(table)
RemoveHTMLTags(text)
RemoveUnwantedCharacters(text, pattern)

// Testing/Validation
TestColorBlindness(color1, color2)
TestColorContrast(foreground, background)

// Statistical calculations
MeasureCorrelation(list1, list2)
MeasureZScore(value, mean, stdDev)

// Data retrieval
GetFactors(number)
GetColorHue(hexColor)
GetFileText(filePath)
```

## Migration Notes

When renaming functions during migration:
1. Update function name in code
2. Update `Documentation.Name` metadata
3. Update test file names to match
4. Update branch names to use new name (e.g., `migrate/Measure-Distance`)
5. Update all documentation references

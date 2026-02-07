# Power Query Function Naming Conventions

## Verb-Noun Format

All functions follow PowerShell-style **Verb-Noun** naming to ensure consistency and IntelliSense-friendly discovery.

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

1. **Use Verb-Noun format**: `Verb-Noun` (e.g., `Get-Distance`, not `CalculateDistance`)
2. **Use approved verbs only**: See the lists above
3. **Use singular nouns**: `Get-Color` not `Get-Colors` (even if it returns multiple)
4. **Use PascalCase**: `Get-ColorScheme` not `getColorScheme` or `get-color-scheme`
5. **Be specific but concise**: `Get-FontColor` not `Get-Font-Color-For-Background`
6. **Avoid synonyms**: Use `Remove-` not `Delete-`, `Eliminate-`, or `Clear-`

## Function Renaming Guide

### Current Functions → Proposed Names

#### Geo Functions
- `Bearing` → `Measure-Bearing` (calculates angular measurement)
- `CalculateDistance` → `Measure-Distance` (calculates distance metric)

#### DateTime Functions  
- `RoundDateTime` → `ConvertTo-RoundedDateTime` (transforms to rounded format)

#### Math Functions
- `Benford` → `Test-Benford` (validates Benford's law)
- `Conf` → `Get-ConfidenceInterval` 
- `Corr` → `Measure-Correlation`
- `ErlangC` → `Get-ErlangC`
- `ExponentialWeightedMovingAverage` → `Measure-EWMA` (or `Measure-ExponentialMovingAverage`)
- `GenerateRandomNumbers` → `New-RandomNumbers`
- `GetFactors` → `Get-Factors`
- `MegaAverage` → `Measure-MegaAverage`
- `MegaStDevS` → `Measure-MegaStandardDeviation`
- `Pearson` → `Measure-Pearson` (or `Measure-PearsonCorrelation`)
- `QuartileStats` → `Get-QuartileStats`
- `Z` → `Measure-ZScore`

#### R Functions
- `RGetLinearModelCoefficients` → `Get-LinearModelCoefficients`
- `RPredictWithLogitModel` → `Invoke-LogitPrediction`

#### SQL Functions
- `RunSQLQuery` → `Invoke-SQLQuery`

#### String Functions
- `EncodeText` → `ConvertTo-EncodedText`
- `ReadFileToText` → `Get-FileText`
- `RemoveHTMLTags` → `Remove-HTMLTags` ✓ (already correct)
- `RemoveUnwantedCharacters` → `Remove-UnwantedCharacters` ✓ (already correct)

#### Tbl Functions
- `ColumnToList` → `ConvertTo-List` (noun could be `ColumnList`)
- `ConvertDateTimeZoneToDate` → `ConvertTo-Date` (or `Convert-DateTimeZone`)
- `RandomNumber` → `New-RandomNumber`
- `RemoveNullColumns` → `Remove-NullColumns` ✓ (already correct)
- `ReplaceInColumnNames` → `Update-ColumnNames` (or `Set-ColumnNames`)
- `RoundColumns` → `ConvertTo-RoundedColumns` (or `Format-Columns`)

#### Utils Functions
- `CreateBatches` → `New-Batches`
- `DynamicSelectList` → `Select-DynamicList`
- `GetFunctionMetadata` → `Get-FunctionMetadata` ✓ (already correct)
- `PostRequest` → `Invoke-PostRequest`
- `Switch` → `Use-Switch` (special case - Switch is reserved in PowerShell)

#### UX Functions
- `CheckColorBlind` → `Test-ColorBlindness` (or `Test-ColorBlindSafety`)
- `CheckColorContrast` → `Test-ColorContrast`
- `CheckWebAimContrast` → `Test-WebAimContrast`
- `GetColorHue` → `Get-ColorHue` ✓ (already correct)
- `GetColorScheme` → `Get-ColorScheme` ✓ (already correct)
- `GetCompColor` → `Get-ComplementaryColor`
- `GetFontColor` → `Get-FontColor` ✓ (already correct)
- `GetHexValue` → `Get-HexValue` ✓ (already correct)
- `GetLuminosity` → `Get-Luminosity` ✓ (already correct)
- `GetRGBValue` → `Get-RGBValue` ✓ (already correct)
- `MedianAspectRatio` → `Measure-MedianAspectRatio`

## Benefits of Verb-Noun Naming

1. **IntelliSense grouping**: Functions group by verb (all `Get-*` together)
2. **Predictable**: Users know `Measure-*` calculates, `Test-*` validates
3. **Consistent**: Same verb means same action across all functions
4. **Discoverable**: Easy to find related functions by filtering on verb
5. **Professional**: Follows established PowerShell/industry standards

## Examples in Context

```powerquery
// Geographic calculations
Measure-Distance(lat1, lon1, lat2, lon2)
Measure-Bearing(lat1, lon1, lat2, lon2)

// Data transformation
ConvertTo-RoundedDateTime(dateTime, precision)
ConvertTo-EncodedText(text, encoding)
Convert-DateTimeZone(table, column)

// Data cleaning
Remove-NullColumns(table)
Remove-HTMLTags(text)
Remove-UnwantedCharacters(text, pattern)

// Testing/Validation
Test-ColorBlindness(color1, color2)
Test-ColorContrast(foreground, background)

// Statistical calculations
Measure-Correlation(list1, list2)
Measure-ZScore(value, mean, stdDev)

// Data retrieval
Get-Factors(number)
Get-ColorHue(hexColor)
Get-FileText(filePath)
```

## Migration Notes

When renaming functions during migration:
1. Update function name in code
2. Update `Documentation.Name` metadata
3. Update test file names to match
4. Update branch names to use new name (e.g., `migrate/Measure-Distance`)
5. Update all documentation references

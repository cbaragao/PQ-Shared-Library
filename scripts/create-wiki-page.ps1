param(
    [string]$RepoOwner = 'cbaragao',
    [string]$RepoName = 'PQ-Shared-Library',
    [string]$PageName = 'Available-Functions.md'
)

Set-StrictMode -Version Latest

$wikiUrl = "https://github.com/$RepoOwner/$RepoName.wiki.git"
$tmp = Join-Path $env:TEMP "pq_wiki_tmp"
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }

git clone $wikiUrl $tmp
if ($LASTEXITCODE -ne 0) { Write-Error 'Git clone failed'; exit 2 }

Set-Location $tmp

$content = @'
# Available Functions

This page lists the Power Query functions included in this repository grouped by folder.

## Note
The previous `sharedmaster` bundling files were removed; functions can be imported individually from the `functions/` folder.

## DateTime
- ConvertToRoundedDateTime

## Geo
- MeasureBearing
- MeasureDistance

## Math
- CalculateEWMA
- GetConfidenceInterval
- GetErlangC
- GetFactors
- NewRandomNumbers
- TestBenford

## R
- GetLinearModelCoefficients
- InvokeLogitPrediction

## SQL
- InvokeSQLQuery

## String
- ConvertToEncodedText
- GetFileText
- RemoveChars
- RemoveHTMLTags

## Tbl
- AddRandomNumber
- ConvertColumnToList
- ConvertDateTimeZoneToDate
- RoundColumns
- UpdateColumnNames

## Utils
- GetFunctionMetadata
- NewBatches
- SelectCase
- SelectDynamicList

## UX
- GetColorHue
- GetColorScheme
- GetCompColor
- GetFontColor
- GetHexValue
- GetLuminosity
- GetMedianAspectRatio
- GetRGBValue
- TestColorBlindness
- TestColorContrast
- TestWebAimContrast

If you want this exported to JSON/CSV or split into per-category pages, tell me and I will generate it.
'@

Set-Content -Path $PageName -Value $content -Encoding UTF8

git add $PageName
git commit -m "Add Available Functions wiki page"
if ($LASTEXITCODE -ne 0) { Write-Error 'Git commit failed or nothing to commit' }

git push origin HEAD

Set-Location $PWD
Remove-Item -Recurse -Force $tmp
Write-Output 'Wiki page created and pushed.'

param(
    [string]$FunctionsDir = 'functions',
    [string]$WikiDir = 'wiki'
)

Set-StrictMode -Version Latest

if (-not (Test-Path $FunctionsDir)) { Write-Error "Functions directory '$FunctionsDir' not found"; exit 2 }
if (-not (Test-Path $WikiDir)) { Write-Error "Wiki directory '$WikiDir' not found"; exit 2 }

# Delete existing .md files in wiki
Get-ChildItem -Path $WikiDir -Filter *.md -File | ForEach-Object {
    Remove-Item -LiteralPath $_.FullName -Force
}

# Process each .pq file
$files = Get-ChildItem -Path $FunctionsDir -Recurse -Filter *.pq | Sort-Object Name
foreach ($f in $files) {
    $raw = Get-Content -Raw -LiteralPath $f.FullName -Encoding UTF8

    # Extract Documentation.LongDescription allowing for doubled quotes inside string
    $longMatch = [regex]::Match($raw, 'Documentation\.LongDescription\s*=\s*"(?s)((?:[^"]|"")*)"')
    $longDesc = if ($longMatch.Success) { ($longMatch.Groups[1].Value -replace '""', '"') } else { '' }

    $fname = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    $mdFile = Join-Path $WikiDir ($fname + '.md')

    $md = "# $fname`n`n"
    if ($longDesc -ne '') { $md += "## Description`n`n$longDesc`n`n" } else { $md += "## Description`n`n_No description available in metadata._`n`n" }

    $md += "## Source`n`n````powerquery`n$raw`n`````n"

    Set-Content -Path $mdFile -Value $md -Encoding UTF8
}

# Commit and push in wiki repo
Push-Location $WikiDir
try {
    git add -A
    git commit -m 'Regenerate wiki function pages from functions/*.pq' -a
    git push origin HEAD
} catch {
    Write-Error "Git commit/push failed: $_"
} finally {
    Pop-Location
}

Write-Output "Generated $($files.Count) wiki pages in '$WikiDir'"

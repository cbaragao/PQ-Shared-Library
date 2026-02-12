param(
    [string]$FunctionsDir = 'functions',
    [string]$WikiDir = 'wiki'
)

Set-StrictMode -Version Latest

if (-not (Test-Path $FunctionsDir)) { Write-Error "Functions directory '$FunctionsDir' not found"; exit 2 }
if (-not (Test-Path $WikiDir)) { Write-Error "Wiki directory '$WikiDir' not found"; exit 2 }

$mdFiles = Get-ChildItem -Path $WikiDir -Filter *.md -File
foreach ($md in $mdFiles) {
    Write-Host "Processing wiki page: $($md.Name)"

    $content = Get-Content -Raw -Encoding UTF8 $md.FullName

    # Remove all backslash-escaped characters (from previous script bug)
    $content = $content -replace '\\([#`n])', '$1'
    $content = $content -replace '\\', ''

    # Replace all lone 'n' (not part of a word) with a newline (for legacy bug)
    $content = $content -replace '(?<![a-zA-Z0-9])n(?![a-zA-Z0-9])', "`n"

    # Remove any duplicate Parameters or Examples sections
    $content = $content -replace '(?ms)^## Parameters.*?(?=^## |\z)', ''
    $content = $content -replace '(?ms)^## Examples.*?(?=^## |\z)', ''

    # Replace PowerShell object interpolation in Result lines with just the result value
    $content = $content -replace 'Result: \$\(@\{[^\}]*Result=([^;\}]+)[^\}]*\}\.Result\)', 'Result: $1'

    # Remove outer fences ```markdown ... ``` if present
    $content = $content -replace '^```markdown\s*', '' -replace '\s*```\s*$', ''

    # Fix code block formatting for examples: ensure ```powerquery ... ```
    $content = $content -replace '(?m)^`powerquery\s*([\s\S]*?)`\s*', '```powerquery`n$1```'

    # Fix function source code block: ensure it starts with ```powerquery and ends with ```
    $content = $content -replace '(```+)[^\n`]*powerquery', '```powerquery'
    $content = $content -replace '(```+)[^\n`]*$', '```'

    # Insert Parameters and Examples after Description heading
    if ($paramsSection -ne '' -or $examplesSection -ne '') {
        $pattern = '(## Description\s*\r?\n(?:.|\r|\n)*?)(\r?\n){2,}'
        $m = [regex]::Match($content, $pattern)
        if ($m.Success) {
            $desc = $m.Groups[1].Value.TrimEnd()
            $rest = $content.Substring($m.Index + $m.Length)
            $content = $desc + "`n`n" + $paramsSection + $examplesSection + "`n" + $rest
        } else {
            $content = $content + "`n" + $paramsSection + $examplesSection
        }
    }

    # Write updated content
    Set-Content -Path $md.FullName -Value $content -Encoding UTF8
}

# Commit and push changes
Push-Location $WikiDir
try {
    git add -A
    git commit -m 'Clean up wiki pages: fences, code blocks, add Parameters and Examples' -a
    git push origin HEAD
} catch {
    Write-Error "Git commit/push failed: $_"
} finally {
    Pop-Location
}

Write-Output "Processed $($mdFiles.Count) wiki pages"

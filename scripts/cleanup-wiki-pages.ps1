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

    # Remove outer fences ```markdown ... ``` if present
    $content = $content -replace '^```markdown\s*', '' -replace '\s*```\s*$', ''

    # Fix code fence markers: replace ``powerquery with ```powerquery and closing `` with ```
    $content = $content -replace '``powerquery', '```powerquery'
    $content = $content -replace "\n``\n", "`n```n"

    # Find corresponding .pq file
    $base = [System.IO.Path]::GetFileNameWithoutExtension($md.Name)
    $pq = Get-ChildItem -Path $FunctionsDir -Recurse -Filter "$base.pq" | Select-Object -First 1
    $paramsSection = ''
    $examplesSection = ''

    if ($pq) {
        $raw = Get-Content -Raw -LiteralPath $pq.FullName -Encoding UTF8

        # Extract fnType parameters
        $fnMatch = [regex]::Match($raw, 'fnType\s*=\s*type function\s*\((?<params>.*?)\)\s*as', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($fnMatch.Success) {
            $paramText = $fnMatch.Groups['params'].Value.Trim()
            if ($paramText -ne '') {
                $paramList = $paramText -split ',' | ForEach-Object { $_.Trim() }
                $paramsSection = "## Parameters`n`n"
                foreach ($p in $paramList) {
                    $paramsSection += "- $p`n"
                }
                $paramsSection += "`n"
            }
        } else {
            # try to extract function signature line
            $sigMatch = [regex]::Match($raw, '^\s*' + [regex]::Escape($base) + '\s*=\s*\((?<params>.*?)\)\s*as', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            if ($sigMatch.Success) {
                $paramText = $sigMatch.Groups['params'].Value.Trim()
                if ($paramText -ne '') {
                    $paramList = $paramText -split ',' | ForEach-Object { $_.Trim() }
                    $paramsSection = "## Parameters`n`n"
                    foreach ($p in $paramList) { $paramsSection += "- $p`n" }
                    $paramsSection += "`n"
                }
            }
        }

        # Extract simple examples: find Code and Description pairs
        $exBlockMatch = [regex]::Match($raw, 'Documentation\.Examples\s*=\s*\{(?<examples>.*?)\}\s*\]', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $examples = @()
        if ($exBlockMatch.Success) {
            $exText = $exBlockMatch.Groups['examples'].Value
            $descMatches = [regex]::Matches($exText, 'Description\s*=\s*"(?<desc>(?:[^"]|""")*)"')
            $codeMatches = [regex]::Matches($exText, 'Code\s*=\s*"(?<code>(?:[^"]|""")*)"')
            $resultMatches = [regex]::Matches($exText, 'Result\s*=\s*"(?<result>(?:[^"]|""")*)"')

            $count = @($descMatches.Count, $codeMatches.Count, $resultMatches.Count) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
            for ($i=0; $i -lt $count; $i++) {
                $d = if ($i -lt $descMatches.Count) { ($descMatches[$i].Groups['desc'].Value -replace '""','"') } else { '' }
                $c = if ($i -lt $codeMatches.Count) { ($codeMatches[$i].Groups['code'].Value -replace '""','"') } else { '' }
                $r = if ($i -lt $resultMatches.Count) { ($resultMatches[$i].Groups['result'].Value -replace '""','"') } else { '' }
                $examples += [PSCustomObject]@{Description=$d; Code=$c; Result=$r}
            }
        }

        if ($examples.Count -gt 0) {
            $examplesSection = "## Examples`n`n"
            foreach ($e in $examples) {
                if ($e.Description -ne '') { $examplesSection += "**$($e.Description)**`n`n" }
                if ($e.Code -ne '') { $examplesSection += "```powerquery`n$($e.Code)`n```n`n" }
                if ($e.Result -ne '') { $examplesSection += "Result: `$($e.Result)`n`n" }
            }
        }
    }


    # Remove any existing Parameters or Examples sections to avoid duplication
    $content = $content -replace '(?ms)^## Parameters.*?(?=^## |\z)', ''
    $content = $content -replace '(?ms)^## Examples.*?(?=^## |\z)', ''

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

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
- **Completed**: 38
- **In Progress**: 0
- **Remaining**: 6
- **Deprecated**: 8 (Corr, Z, QuartileStats, MegaAverage, MegaStDevS, Pearson, RemoveNullColumns, RoundColumns)
- **Progress**: 86% complete (38/44 functions)

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

---

## Last Updated
This project plan was last updated on 2026-02-11.

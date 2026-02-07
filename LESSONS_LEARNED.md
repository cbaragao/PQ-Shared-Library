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
- **Function(s)**: RoundDateTime
- **Category**: PQLint
- **Severity**: Medium
- **Problem**: PQLint rule `use-culture-for-date-functions` and `use-culture-for-numeric-functions` flagged missing culture parameter in `Number.From()` and `DateTime.From()` functions. Without explicit culture, output may vary based on user's machine locale.
- **Solution**: Add `"en-US"` as second parameter to both `Number.From(dt, "en-US")` and `DateTime.From(Rounded, "en-US")` to ensure predictable output regardless of user locale.
- **Prevention**: Always include culture parameter when using date/time or numeric conversion functions. Default to `"en-US"` unless specific locale is required.

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

---

## Migration Pattern Library

Common patterns and their simplified equivalents will be documented here as they're discovered.

_To be populated during migration._

---

## Git/Branch Management Issues

_To be populated with any git-related issues encountered._

---

## Last Updated
This document was created on 2026-02-07 and will be updated throughout the migration process.

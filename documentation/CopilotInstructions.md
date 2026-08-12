# Power Query Copilot Guidance

Active workspace instructions live in [`.github/copilot-instructions.md`](../.github/copilot-instructions.md) and [`.github/instructions/`](../.github/instructions/). This reference is retained for readers who browse the documentation directory.

New and migrated functions use direct typed function syntax, not `Function.From`:

```powerquery
let
    FunctionName = (parameter as type) as returnType =>
        let
            result = parameter
        in
            result,
    fnType = type function (parameter as type) as returnType
        meta [
            Documentation.Name = "FunctionName",
            Documentation.LongDescription = "Description.",
            Documentation.Examples = {
                [
                    Description = "Example description.",
                    Code = "=FunctionName(value)",
                    Result = "Expected result"
                ]
            }
        ]
in
    Value.ReplaceType(FunctionName, fnType)
```

Use PascalCase names without hyphens for identifiers and files. Examples must call the real identifier. Test queries embed the parent function instead of loading a local source file, so they remain portable to Power BI Desktop.
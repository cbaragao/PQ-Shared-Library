# Copilot Instructions for Creating a Power Query (.pq) File

## Overview
This document provides instructions for creating a Power Query (.pq) file in the format used in this workspace. The structure ensures consistency, readability, and proper metadata documentation for each function.

## File Structure
Each Power Query file should follow this structure:

1. **Function Definition**: Start with a `let` statement that defines the function name.
2. **Function Implementation**: Use `Function.From` to define the function logic.
3. **Metadata and Examples**: At the end of the file, provide metadata and examples using `fnType`.

## Steps to Create a New Function

### 1. Define the Function Name
Start with a `let` statement to define the function name. For example:

```powerquery
let
    FunctionName =
```

### 2. Implement the Function Logic
Use `Function.From` to define the function logic. The function should take parameters and return the desired output. For example:

```powerquery
Function.From(type function(Parameter1 as type1, Parameter2 as type2) as returnType, (params) =>
    let
        // Function logic goes here
    in
        Result
),
```

### 3. Add Metadata and Examples
At the end of the file, provide metadata and examples using `fnType`. This includes:
- Function type
- Documentation name
- Long description
- Examples

For example:

```powerquery
fnType = type function (Parameter1 as type1, Parameter2 as type2) as returnType meta
[
    Documentation.Name = "FunctionName",
    Documentation.LongDescription = "This function performs ...",
    Documentation.Examples = {
        [
            Description = "Example description.",
            Code = "FunctionName(Argument1, Argument2)",
            Result = "Expected result"
        ]
    }
]
in
Value.ReplaceType(FunctionName, fnType)
```

## Example Template
Below is a complete example template for creating a new function:

```powerquery
let
    NewFunction =
    Function.From(type function(Parameter1 as type1, Parameter2 as type2) as returnType, (params) =>
        let
            // Function logic goes here
        in
            Result
    ),

fnType = type function (Parameter1 as type1, Parameter2 as type2) as returnType meta
[
    Documentation.Name = "NewFunction",
    Documentation.LongDescription = "This function performs ...",
    Documentation.Examples = {
        [
            Description = "Example description.",
            Code = "NewFunction(Argument1, Argument2)",
            Result = "Expected result"
        ]
    }
]
in
Value.ReplaceType(NewFunction, fnType)
```

## Commenting and Formatting
- **Commenting**: Add comments to explain each step of the function logic.
- **Formatting**: Use consistent indentation and spacing for readability.

## Automation
To automate the creation of a new function:
1. Paste the inner function logic into the template.
2. Add comments and metadata.
3. Format the code consistently.

By following these instructions, you can ensure that all Power Query files in this workspace are structured and documented consistently.
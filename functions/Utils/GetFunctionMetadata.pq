let
  // Define the function using simplified syntax
  GetFunctionMetadata = (function_name as text, return as text, optional culture as nullable text) as any =>
      let
        // Use default culture if not provided
        cultureToUse = culture ?? "en-US",
        
        // Retrieve metadata for the given function name
        metadata = Value.Metadata(
          Value.Type(
            Table.SelectRows(
              Record.ToTable(#shared), 
              each [Name] = function_name
            )[Value]{0}
          )
        ),
        
        // Determine the result based on the 'return' parameter
        returnLower = Text.Lower(return, cultureToUse),
        result = 
          if returnLower = "name" then
            metadata[Documentation.Name]
          else if returnLower = "description" then
            metadata[Documentation.Description]
          else if returnLower = "example" then
            metadata[Documentation.Examples]{0}
          else
            "Invalid return parameter value provided"
      in
        result,

  // Define the function type with metadata
  fnType = type function (
    function_name as text, 
    return as text, 
    optional culture as nullable text
  ) as any
    meta [
      Documentation.Name = "Get-FunctionMetadata",
      Documentation.LongDescription = "Retrieves metadata for a given function name from the #shared environment. Returns the requested metadata field (name, description, or example) based on the return parameter. Optionally accepts a culture parameter for text comparisons.",
      Documentation.Examples = {
        [
          Description = "Get the name of a function.",
          Code        = "GetFunctionMetadata(""Table.SelectRows"", ""name"")",
          Result      = """Table.SelectRows"""
        ],
        [
          Description = "Get the description of a function.",
          Code        = "GetFunctionMetadata(""Table.SelectRows"", ""description"")",
          Result      = """Returns a table that contains only the rows that match a condition."""
        ],
        [
          Description = "Get an example of a function.",
          Code        = "GetFunctionMetadata(""Table.Group"", ""example"")",
          Result      = "First example record from the function's documentation"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetFunctionMetadata, fnType)
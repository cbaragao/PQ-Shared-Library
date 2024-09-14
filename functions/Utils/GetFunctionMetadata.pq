let
  // Define the function using Function.From
  GetFunctionMetadata = Function.From(
    type function (function_name as text, return as text) as text,
    (params) =>
      let
        // Retrieve metadata for the given function name
        metadata = Value.Metadata(
          Value.Type(
            Table.SelectRows(Record.ToTable(#shared), each _[Name] = params{0})[Value]{0}
          )
        ),
        // Determine the result based on the 'return' parameter
        result = 
          if Text.Lower(params{1}) = "name" then
            metadata[Documentation.Name]
          else if Text.Lower(params{1}) = "description" then
            metadata[Documentation.Description]
          else if Text.Lower(params{1}) = "example" then
            metadata[Documentation.Examples]{0}
          else
            "Invalid return parameter value provided"
      in
        result
  ),

  // Define the function type with metadata
  fnType = type function (function_name as text, return as text) as text
    meta [
      Documentation.Name = "GetFunctionMetadata",
      Documentation.LongDescription = "This function takes a function name and return type (name, description, or example) and provides the metadata associated with the function.",
      Documentation.Examples = {
        [
          Description = "Get the name of a function.",
          Code        = "=GetFunctionMetadata(""Table.SelectRows"", ""name"")",
          Result      = "Table.SelectRows"
        ],
        [
          Description = "Get the description of a function.",
          Code        = "=GetFunctionMetadata(""Table.SelectRows"", ""description"")",
          Result      = "Returns a table that contains only the rows that match a condition."
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetFunctionMetadata, fnType)
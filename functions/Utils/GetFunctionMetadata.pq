let
  // Define the function using Function.From
  GetFunctionMetadata =  (function_name as text, return as text) as text =>
      let
        // Retrieve metadata for the given function name
        metadata = Value.Metadata(
          Value.Type(
            Table.SelectRows(Record.ToTable(#shared), each _[Name] = function_name)[Value]{0}
          )
        ),
        // Determine the result based on the 'return' parameter
        result = 
          if Text.Lower(return) = "name" then
            metadata[Documentation.Name]
          else if Text.Lower(return) = "description" then
            metadata[Documentation.Description]
          else
            "Invalid return parameter value provided"
      in
        result
  ,

  // Define the function type with metadata
  fnType = type function (function_name as text, return as text) as text
    meta [
      Documentation.Name = "GetFunctionMetadata",
      Documentation.LongDescription = "This function takes a function name and return type (name, description) and provides the metadata associated with the function.",
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
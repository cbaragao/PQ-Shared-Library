let
  ConvertColumnToList = (t as table, column_name as text) as list =>
    let
      // Convert the specified column to a list
      result = Table.ToList(
        Table.TransformColumnTypes(
          Table.SelectColumns(t, {column_name}, MissingField.Error),
          {column_name, type text}
        )
      )
    in
      result, 
  fnType = type function (t as table, column_name as text) as list
    meta [
      Documentation.Name = "ConvertColumnToList", 
      Documentation.LongDescription = "This function converts a specified column from a given table into a list. It takes a table and a column name as input, transforms the column to text type, and returns it as a list.",
      Documentation.Examples = {
        [
          Description = "Convert the 'A' column of a table to a list.",
          Code        = "ConvertColumnToList(#table({\"\"A\"\", \"\"B\"\"}, {{1, 2}, {3, 4}}), \"\"A\"\")", 
          Result      = "{1, 3}"
        ],
        [
          Description = "Convert the 'Name' column to a list.",
          Code        = "ConvertColumnToList(#table({\"\"Name\"\", \"\"Age\"\"}, {{\"\"John\"\", 25}, {\"\"Jane\"\", 30}}), \"\"Name\"\")",
          Result      = "{\"\"John\"\", \"\"Jane\"\"}"
        ]
      }
    ]
in
  Value.ReplaceType(ConvertColumnToList, fnType)
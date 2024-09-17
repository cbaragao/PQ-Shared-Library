let
  RoundColumns = Function.From(
    type function (t as table, decimal_places as number, optional exclusions as list) as table, 
    (params) =>
      let
        // Select columns that are of type Number
        Columns = Table.SelectRows(Table.Schema(params{0}), each _[TypeName] = "Number.Type")[Name],
        // Exclude any columns that do not need to be rounded
        Exclude = try List.RemoveItems(Columns, params{2}) otherwise {},
        // Create a list of transformation functions for rounding numbers
        Zip = List.Zip({Exclude, List.Repeat({(num) as number => Number.RoundAwayFromZero(num, params{1})}, List.Count(Exclude))}),
        // Apply the rounding transformation to the columns
        Txform = Table.TransformColumns(params{0}, Zip)
      in
        Txform
  ), 
  fnType = type function (t as table, decimal_places as number, optional exclusions as list) as table
    meta [
      Documentation.Name = "RoundColumns", 
      Documentation.LongDescription = "This function rounds the values in all numeric columns of a given table to a specified number of decimal places. It takes a table, the number of decimal places, and an optional list of columns to exclude as input and returns the table with rounded values.",
      Documentation.Examples = {
        [
          Description = "Round the values in numeric columns of a table to 2 decimal places.",
          Code        = "=RoundColumns(Table.TransformColumnTypes(#table({""A"", ""B""}, {{1.234, 2.345}, {3.456, 4.567}}),{{""A"", type number}, {""B"", type number}}), 2)", 
          Result      = "#table({""A"", ""B""}, {{1.23, 2.35}, {3.46, 4.57}})"
        ],
        [
          Description = "Round the values in numeric columns of a table to 2 decimal places, excluding the 'B' column.",
          Code        = "=RoundColumns(Table.TransformColumnTypes(#table({""A"", ""B""}, {{1.234, 2.345}, {3.456, 4.567}}),{{""A"", type number}, {""B"", type number}}), 2, {""B""})", 
          Result      = "#table({""A"", ""B""}, {{1.23, 2.345}, {3.46, 4.567}})"
        ]
      }
    ]
in
  Value.ReplaceType(RoundColumns, fnType)
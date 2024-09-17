let
  Source = Function.From(
    type function (t as table, column_name as text) as list, 
    (params) =>
      let
        // Convert the specified column to a list
        ColumnToList = Table.ToList(
                          Table.TransformColumnTypes(
                            Table.SelectColumns(
                              params{0}, 
                              {params{1}}
                            ),
                            {params{1}, 
                            type text}
                          )
                        )
      in
        ColumnToList
  ), 
  fnType = type function (t as table, column_name as text) as list
    meta [
      Documentation.Name = "ColumnToList", 
      Documentation.LongDescription = "This function converts a specified column from a given table into a list. It takes a table and a column name as input and returns the column as a list.",
      Documentation.Examples = {
        [
          Description = "Convert the 'A' column of a table to a list.",
          Code        = "=ColumnToList(#table({""A"", ""B""}, {{1, 2}, {3, 4}}), ""A"")", 
          Result      = "{1, 3}"
        ]
      }
    ]
in
  Value.ReplaceType(Source, fnType)
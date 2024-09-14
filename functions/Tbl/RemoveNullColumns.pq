let
  RemoveNullColumns = Function.From(
    type function (tbl as table) as table, 
    (params) =>
      let
        // Select columns that are not completely null
        Source = 
          Table.SelectColumns(
            params{0}, 
            // Select all non-null column names
            Table.SelectRows(
              // Add a helper column for filtering null columns
              Table.AddColumn(
                Table.Profile(params{0}), 
                "IsNull", 
                each if [Count] = Number.From([NullCount]) then 1 else 0, 
                type number
              ), 
              each _[IsNull] = 0
            )[Column]
          )
      in
        Source
  ), 
  fnType = type function (tbl as table) as table
    meta [
      Documentation.Name = "RemoveNullColumns", 
      Documentation.LongDescription = "This function removes columns that are completely null from a given table. It takes a table as input and returns the table with only the columns that contain non-null values.",
      Documentation.Examples = {
        [
          Description = "Remove columns that are completely null from a table.",
          Code        = "=RemoveNullColumns(#table({""A"", ""B""}, {{1, null}, {2, null}}))", 
          Result      = "#table({""A""}, {{1}, {2}})"
        ]
      }
    ]
in
  Value.ReplaceType(RemoveNullColumns, fnType)

let
  GetSchemaComparison = (t1 as table, t2 as table) as table =>
    let
      // Extract column name/type pairs from a table's schema, renaming to caller-supplied labels
      getColumnSchema = (t as table, nameColumn as text, typeColumn as text) as table =>
        let
          schema = Table.Schema(t),
          selected = Table.SelectColumns(schema, {"Name", "TypeName"}, MissingField.Error),
          renamed = Table.RenameColumns(selected, {{"Name", nameColumn}, {"TypeName", typeColumn}})
        in
          renamed,

      schema1 = getColumnSchema(t1, "Column1", "FirstTable"),
      schema2 = getColumnSchema(t2, "Column2", "SecondTable"),

      // Full outer join surfaces every column name found in either table, with nulls where a column is missing from one side
      joined = Table.Join(schema1, "Column1", schema2, "Column2", JoinKind.FullOuter),

      withStatus = Table.AddColumn(
        joined,
        "Status",
        each
          if [FirstTable] = [SecondTable] then "Match"
          else if [FirstTable] = null and [SecondTable] <> null then "Added"
          else if [FirstTable] <> null and [SecondTable] = null then "Removed"
          else if [FirstTable] <> [SecondTable] then "Type Changed"
          else "Unknown",
        type text
      ),

      // Column1 and Column2 are never both null for a joined row, so coalescing recovers the shared column name
      withColumn = Table.AddColumn(withStatus, "Column", each [Column1] ?? [Column2], type text),

      result = Table.SelectColumns(withColumn, {"Column", "FirstTable", "SecondTable", "Status"}, MissingField.Error)
    in
      result,

  fnType = type function (t1 as table, t2 as table) as table
    meta [
      Documentation.Name = "GetSchemaComparison",
      Documentation.LongDescription = "Compares the column schemas of two tables and classifies each distinct column name as Match (present in both tables with the same type), Added (present only in the second table), Removed (present only in the first table), or Type Changed (present in both tables with different types). Returns a table with one row per column name found in either table, the type name reported by each table (null when the column is absent from that table), and the resulting Status.",
      Documentation.Examples = {
        [
          Description = "Compare two tables that share the same column names and types.",
          Code = "GetSchemaComparison(#table(type table [ID = number, Name = text], {}), #table(type table [ID = number, Name = text], {}))",
          Result = "#table({""Column"", ""FirstTable"", ""SecondTable"", ""Status""}, {{""ID"", ""Number.Type"", ""Number.Type"", ""Match""}, {""Name"", ""Text.Type"", ""Text.Type"", ""Match""}})"
        ],
        [
          Description = "Compare two tables with an added column, a removed column, and a column whose type changed.",
          Code = "GetSchemaComparison(#table(type table [ID = number, Name = text, Amount = number], {}), #table(type table [ID = text, Name = text, Active = logical], {}))",
          Result = "#table({""Column"", ""FirstTable"", ""SecondTable"", ""Status""}, {{""ID"", ""Number.Type"", ""Text.Type"", ""Type Changed""}, {""Name"", ""Text.Type"", ""Text.Type"", ""Match""}, {""Amount"", ""Number.Type"", null, ""Removed""}, {""Active"", null, ""Logical.Type"", ""Added""}})"
        ]
      }
    ]
in
  Value.ReplaceType(GetSchemaComparison, fnType)

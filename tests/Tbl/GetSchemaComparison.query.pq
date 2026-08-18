let
  // Include function being tested
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

  // Helper to fetch a single result row by Column name, independent of join order
  GetRow = (t as table, columnName as text) as record =>
    Table.SelectRows(t, each [Column] = columnName){0},

  // Test 1: Identical schemas produce a Match for every column
  Test1_Input1 = #table(type table [ID = number, Name = text], {{1, "Alice"}}),
  Test1_Input2 = #table(type table [ID = number, Name = text], {{2, "Bob"}}),
  Test1_Result = GetSchemaComparison(Test1_Input1, Test1_Input2),
  Test1_RowCount = Table.RowCount(Test1_Result) = 2,
  Test1_AllMatch = List.AllTrue(List.Transform(Table.Column(Test1_Result, "Status"), each _ = "Match")),
  Test1_Pass = Test1_RowCount and Test1_AllMatch,

  // Test 2: Added, Removed, and Type Changed columns are classified correctly
  Test2_Input1 = #table(type table [ID = number, Name = text, Amount = number], {{1, "A", 10}}),
  Test2_Input2 = #table(type table [ID = text, Name = text, Active = logical], {{"1", "A", true}}),
  Test2_Result = GetSchemaComparison(Test2_Input1, Test2_Input2),
  Test2_RowCount = Table.RowCount(Test2_Result) = 4,
  Test2_ID_Status = GetRow(Test2_Result, "ID")[Status] = "Type Changed",
  Test2_Name_Status = GetRow(Test2_Result, "Name")[Status] = "Match",
  Test2_Amount_Status = GetRow(Test2_Result, "Amount")[Status] = "Removed",
  Test2_Active_Status = GetRow(Test2_Result, "Active")[Status] = "Added",
  Test2_Pass = Test2_RowCount and Test2_ID_Status and Test2_Name_Status and Test2_Amount_Status and Test2_Active_Status,

  // Test 3: Completely disjoint schemas classify every column as Removed or Added
  Test3_Input1 = #table(type table [A = number], {{1}}),
  Test3_Input2 = #table(type table [B = text], {{"x"}}),
  Test3_Result = GetSchemaComparison(Test3_Input1, Test3_Input2),
  Test3_RowCount = Table.RowCount(Test3_Result) = 2,
  Test3_A_Status = GetRow(Test3_Result, "A")[Status] = "Removed",
  Test3_B_Status = GetRow(Test3_Result, "B")[Status] = "Added",
  Test3_Pass = Test3_RowCount and Test3_A_Status and Test3_B_Status,

  // Test 4: Boundary case - tables with no columns produce an empty comparison
  Test4_Input1 = #table({}, {}),
  Test4_Input2 = #table({}, {}),
  Test4_Result = GetSchemaComparison(Test4_Input1, Test4_Input2),
  Test4_Pass = Table.RowCount(Test4_Result) = 0,

  // Test 5: Null handling - a null argument in place of a table raises an error
  Test5_Result = try GetSchemaComparison(null, #table(type table [A = number], {})) otherwise "Error",
  Test5_Pass = Test5_Result = "Error",

  // Test 6: Row data does not affect the comparison, only column schema
  Test6_Input1 = #table(type table [ID = number], {}),
  Test6_Input2 = #table(type table [ID = number], {{1}, {2}, {3}}),
  Test6_Result = GetSchemaComparison(Test6_Input1, Test6_Input2),
  Test6_Pass = Table.RowCount(Test6_Result) = 1 and GetRow(Test6_Result, "ID")[Status] = "Match",

  // Consolidate test results
  TestResults = #table(
    {"TestCase", "Expected", "Pass"},
    {
      {"Test1: Identical schemas are all Match", true, Test1_Pass},
      {"Test2: Added/Removed/Type Changed classified correctly", true, Test2_Pass},
      {"Test3: Disjoint schemas are Removed/Added", true, Test3_Pass},
      {"Test4: Tables with no columns produce empty result", true, Test4_Pass},
      {"Test5: Null table argument raises an error", true, Test5_Pass},
      {"Test6: Comparison ignores row data, only schema", true, Test6_Pass}
    }
  )
in
  TestResults

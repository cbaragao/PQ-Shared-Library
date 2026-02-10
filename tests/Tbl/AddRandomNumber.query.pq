let
  // Include function being tested
  AddRandomNumber = (t as table, seed as number) as table =>
    let
      // Step 1: Add an index column to the input table to preserve row order and enable alignment
      Source = Table.AddIndexColumn(t, "__Index", 0, 1, Int64.Type),

      // Step 2: Generate a reproducible list of random numbers using the provided seed
      // This ensures consistent output across refreshes or deployments
      Random_List = List.Random(Table.RowCount(t), seed),

      // Step 3: Convert the random list into a table and add an index column for joining
      Add_Index_To_Random_List = Table.AddIndexColumn(
        Table.FromList(
          Random_List,
          Splitter.SplitByNothing(),
          type table [Random = Number.Type],
          null,
          ExtraValues.Error
        ),
        "__Index",
        0,
        1
      ),

      // Step 4: Join the original table with the random number table using the index
      // This aligns each original row with its corresponding random value
      Join_Tables = Table.Join(
        Source,
        "__Index",
        Add_Index_To_Random_List,
        "__Index",
        JoinKind.Inner
      ),

      // Step 5: Remove the temporary index column to clean up the final output
      Result = Table.RemoveColumns(Join_Tables, "__Index", MissingField.Ignore)
    in
      Result,

  // Test cases
  Test1_Input = #table({"ID"}, {{1}, {2}, {3}}),
  Test1_Result = AddRandomNumber(Test1_Input, 12345),
  Test1_HasRandomColumn = List.Contains(Table.ColumnNames(Test1_Result), "Random"),
  Test1_RowCount = Table.RowCount(Test1_Result) = 3,
  
  Test2_Input = #table({"Name"}, {{"A"}, {"B"}}),
  Test2_Result = AddRandomNumber(Test2_Input, 99),
  Test2_HasRandomColumn = List.Contains(Table.ColumnNames(Test2_Result), "Random"),
  Test2_RowCount = Table.RowCount(Test2_Result) = 2,
  
  // Test reproducibility - same seed should produce same results
  Test3_Input = #table({"Value"}, {{100}, {200}}),
  Test3_Result1 = AddRandomNumber(Test3_Input, 555),
  Test3_Result2 = AddRandomNumber(Test3_Input, 555),
  Test3_Reproducible = Test3_Result1 = Test3_Result2,
  
  // Test single row table
  Test4_Input = #table({"X"}, {{1}}),
  Test4_Result = AddRandomNumber(Test4_Input, 1),
  Test4_HasRandomColumn = List.Contains(Table.ColumnNames(Test4_Result), "Random"),
  Test4_RowCount = Table.RowCount(Test4_Result) = 1,

  // Test with empty table
  Test5_Input = #table({"Column"}, {}),
  Test5_Result = AddRandomNumber(Test5_Input, 123),
  Test5_HasRandomColumn = List.Contains(Table.ColumnNames(Test5_Result), "Random"),
  Test5_RowCount = Table.RowCount(Test5_Result) = 0,

  // Consolidate test results
  TestResults = #table(
    {"TestCase", "Expected", "Actual", "Pass"},
    {
      {"Test1: 3-row table has Random column", true, Test1_HasRandomColumn, Test1_HasRandomColumn = true},
      {"Test1: Row count preserved", true, Test1_RowCount, Test1_RowCount = true},
      {"Test2: 2-row table has Random column", true, Test2_HasRandomColumn, Test2_HasRandomColumn = true},
      {"Test2: Row count preserved", true, Test2_RowCount, Test2_RowCount = true},
      {"Test3: Same seed produces identical results", true, Test3_Reproducible, Test3_Reproducible = true},
      {"Test4: Single row has Random column", true, Test4_HasRandomColumn, Test4_HasRandomColumn = true},
      {"Test4: Single row count preserved", true, Test4_RowCount, Test4_RowCount = true},
      {"Test5: Empty table has Random column", true, Test5_HasRandomColumn, Test5_HasRandomColumn = true},
      {"Test5: Empty table row count is 0", true, Test5_RowCount, Test5_RowCount = true}
    }
  )
in
  TestResults

let
  // Include function being tested
  UpdateColumnNames = (t as table, search as text, replacement as text, optional culture as text) as table =>
    let
      cultureValue = culture ?? "en-US",
      
      // Replace text in column names and apply Text.Proper to make proper case
      // Based on Alex Powers's solution
      Result = Table.TransformColumnNames(
        t,
        each Text.Proper(
          Replacer.ReplaceText(_, search, replacement),
          cultureValue
        )
      )
    in
      Result,

  // Test 1: Replace underscores with spaces
  Test1_Input = #table({"first_name", "last_name"}, {{"John", "Doe"}}),
  Test1_Result = UpdateColumnNames(Test1_Input, "_", " "),
  Test1_Columns = Table.ColumnNames(Test1_Result),
  Test1_Pass = Test1_Columns = {"First Name", "Last Name"},

  // Test 2: Replace hyphens with underscores
  Test2_Input = #table({"col-a", "col-b"}, {{1, 2}}),
  Test2_Result = UpdateColumnNames(Test2_Input, "-", "_"),
  Test2_Columns = Table.ColumnNames(Test2_Result),
  Test2_Pass = Test2_Columns = {"Col_A", "Col_B"},

  // Test 3: No match - Text.Proper still applied
  Test3_Input = #table({"column_one", "column_two"}, {{1, 2}}),
  Test3_Result = UpdateColumnNames(Test3_Input, "-", " "),
  Test3_Columns = Table.ColumnNames(Test3_Result),
  Test3_Pass = Test3_Columns = {"Column_One", "Column_Two"},

  // Test 4: Multiple occurrences in same column name
  Test4_Input = #table({"a_b_c", "x_y_z"}, {{1, 2}}),
  Test4_Result = UpdateColumnNames(Test4_Input, "_", " "),
  Test4_Columns = Table.ColumnNames(Test4_Result),
  Test4_Pass = Test4_Columns = {"A B C", "X Y Z"},

  // Test 5: Empty replacement
  Test5_Input = #table({"remove_this_text", "another_text"}, {{1, 2}}),
  Test5_Result = UpdateColumnNames(Test5_Input, "_text", ""),
  Test5_Columns = Table.ColumnNames(Test5_Result),
  Test5_Pass = Test5_Columns = {"Remove_This", "Another"},

  // Consolidate test results
  TestResults = #table(
    {"TestCase", "Expected", "Actual", "Pass"},
    {
      {"Test1: Replace underscore with space", "First Name, Last Name", Text.Combine(Test1_Columns, ", "), Test1_Pass},
      {"Test2: Replace hyphen with underscore", "Col_A, Col_B", Text.Combine(Test2_Columns, ", "), Test2_Pass},
      {"Test3: No match - Text.Proper applied", "Column_One, Column_Two", Text.Combine(Test3_Columns, ", "), Test3_Pass},
      {"Test4: Multiple occurrences replaced", "A B C, X Y Z", Text.Combine(Test4_Columns, ", "), Test4_Pass},
      {"Test5: Empty replacement string", "Remove_This, Another", Text.Combine(Test5_Columns, ", "), Test5_Pass}
    }
  )
in
  TestResults

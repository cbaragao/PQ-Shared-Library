let
  // Function being tested
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
  
  // Test cases
  Source = #table(
    {"TestCase", "Input", "Expected", "Actual", "Pass"},
    {
      {
        "Example 1: Convert column A with numbers",
        #table({"A", "B"}, {{1, 2}, {3, 4}}),
        {"1", "3"},
        ConvertColumnToList(#table({"A", "B"}, {{1, 2}, {3, 4}}), "A"),
        ConvertColumnToList(#table({"A", "B"}, {{1, 2}, {3, 4}}), "A") = {"1", "3"}
      },
      {
        "Example 2: Convert Name column with text",
        #table({"Name", "Age"}, {{"John", 25}, {"Jane", 30}}),
        {"John", "Jane"},
        ConvertColumnToList(#table({"Name", "Age"}, {{"John", 25}, {"Jane", 30}}), "Name"),
        ConvertColumnToList(#table({"Name", "Age"}, {{"John", 25}, {"Jane", 30}}), "Name") = {"John", "Jane"}
      },
      {
        "Test: Convert column B",
        #table({"A", "B"}, {{1, 2}, {3, 4}}),
        {"2", "4"},
        ConvertColumnToList(#table({"A", "B"}, {{1, 2}, {3, 4}}), "B"),
        ConvertColumnToList(#table({"A", "B"}, {{1, 2}, {3, 4}}), "B") = {"2", "4"}
      },
      {
        "Test: Single row table",
        #table({"X"}, {{100}}),
        {"100"},
        ConvertColumnToList(#table({"X"}, {{100}}), "X"),
        ConvertColumnToList(#table({"X"}, {{100}}), "X") = {"100"}
      },
      {
        "Test: Empty table",
        #table({"Col"}, {}),
        {},
        ConvertColumnToList(#table({"Col"}, {}), "Col"),
        ConvertColumnToList(#table({"Col"}, {}), "Col") = {}
      }
    }
  )
in
  Source

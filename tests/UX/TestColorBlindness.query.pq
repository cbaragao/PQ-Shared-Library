let
    // Load the function from file
    TestColorBlindness = Expression.Evaluate(Text.FromBinary(File.Contents("functions/UX/TestColorBlindness.pq")), #shared),
    
    // Test 1: Validate function is callable (type check)
   test1 = Value.Type(TestColorBlindness),
    result1 = if Type.Is(test1, type function) then "Test 1 Passed" else "Test 1 Failed",
    
    // Test 2: Test with basic red color
    test2 = TestColorBlindness("#FF0000"),
    result2 = if Table.RowCount(test2) = 11 and Table.ColumnCount(test2) = 4 then "Test 2 Passed" else "Test 2 Failed",
    
    // Test 3: Test with blue color
    test3 = TestColorBlindness("#0000FF"),
    result3 = if Table.RowCount(test3) = 11 then "Test 3 Passed" else "Test 3 Failed",
    
   // Test 4: Verify column names
    test4Cols = Table.ColumnNames(TestColorBlindness("#00FF00")),
    expected4Cols = {"Severity", "Protanomaly", "Deuteranomaly", "Tritanomaly"},
    result4 = if test4Cols = expected4Cols then "Test 4 Passed" else "Test 4 Failed",
    
    // Test 5: Verify severity column has correct values (0.0 to 1.0)
    test5 = TestColorBlindness("#FFFFFF"),
    severities = Table.Column(test5, "Severity"),
    result5 = if List.First(severities) = 0 and List.Last(severities) = 1 then "Test 5 Passed" else "Test 5 Failed",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Function is callable", result1},
            {"Test 2: Red color produces 11 rows, 4 columns", result2},
            {"Test 3: Blue color produces 11 rows", result3},
            {"Test 4: Column names are correct", result4},
            {"Test 5: Severity values range from 0 to 1", result5}
        }
    )
in
    summary

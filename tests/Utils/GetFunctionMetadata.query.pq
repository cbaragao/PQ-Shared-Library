let
    // Load the function from file
    GetFunctionMetadata = Expression.Evaluate(Text.FromBinary(File.Contents("functions/Utils/GetFunctionMetadata.pq")), #shared),
    
    // Test 1: Get name of a function
    test1 = GetFunctionMetadata("Table.SelectRows", "name"),
    result1 = if test1 = "Table.SelectRows" then "Test 1 Passed" else "Test 1 Failed: " & Text.From(test1, "en-US"),
    
    // Test 2: Get description of a function
    test2 = GetFunctionMetadata("Table.SelectRows", "description"),
    result2 = if Text.Contains(test2, "rows", Comparer.OrdinalIgnoreCase) then "Test 2 Passed" else "Test 2 Failed",
    
    // Test 3: Get example of a function
    test3 = GetFunctionMetadata("Table.Group", "example"),
    result3 = if test3 <> null and test3 <> "Invalid return parameter value provided" then "Test 3 Passed" else "Test 3 Failed",
    
    // Test 4: Test with uppercase return parameter (should be case-insensitive)
    test4 = GetFunctionMetadata("List.Sum", "NAME"),
    result4 = if test4 = "List.Sum" then "Test 4 Passed" else "Test 4 Failed",
    
    // Test 5: Test with invalid return parameter
    test5 = GetFunctionMetadata("Table.SelectRows", "invalid"),
    result5 = if test5 = "Invalid return parameter value provided" then "Test 5 Passed" else "Test 5 Failed",
    
    // Test 6: Test with custom culture parameter
    test6 = GetFunctionMetadata("Text.Upper", "description", "en-US"),
    result6 = if test6 <> null and test6 <> "Invalid return parameter value provided" then "Test 6 Passed" else "Test 6 Failed",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Get function name", result1},
            {"Test 2: Get function description", result2},
            {"Test 3: Get function example", result3},
            {"Test 4: Case-insensitive return parameter", result4},
            {"Test 5: Invalid return parameter", result5},
            {"Test 6: Custom culture parameter", result6}
        }
    )
in
    summary

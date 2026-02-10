let
    // Load the function from file
    SelectDynamicList = Expression.Evaluate(Text.FromBinary(File.Contents("functions/Utils/SelectDynamicList.pq")), #shared),
    
    // Test 1: Select specific items and ranges from a list of strings
    testList1 = {"A", "B", "C", "D", "E"},
    test1 = SelectDynamicList(testList1, {"A", "C:E"}),
    result1 = if test1 = {"A", "C", "D", "E"} then "Test 1 Passed" else "Test 1 Failed",
    
    // Test 2: Select multiple ranges and individual items from numeric list
    testList2 = {1, 2, 3, 4, 5, 6, 7, 8},
    test2 = SelectDynamicList(testList2, {1, "3:5", 8}),
    result2 = if test2 = {1, 3, 4, 5, 8} then "Test 2 Passed" else "Test 2 Failed",
    
    // Test 3: Select only individual items (no ranges)
    testList3 = {"X", "Y", "Z"},
    test3 = SelectDynamicList(testList3, {"X", "Z"}),
    result3 = if test3 = {"X", "Z"} then "Test 3 Passed" else "Test 3 Failed",
    
    // Test 4: Select only a range
    testList4 = {10, 20, 30, 40, 50},
    test4 = SelectDynamicList(testList4, {"20:40"}),
    result4 = if test4 = {20, 30, 40} then "Test 4 Passed" else "Test 4 Failed",
    
    // Test 5: Select single item at start
    testList5 = {"First", "Second", "Third"},
    test5 = SelectDynamicList(testList5, {"First"}),
    result5 = if test5 = {"First"} then "Test 5 Passed" else "Test 5 Failed",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Select items and ranges from strings", result1},
            {"Test 2: Select from numeric list with ranges", result2},
            {"Test 3: Select only individual items", result3},
            {"Test 4: Select only a range", result4},
            {"Test 5: Select single item", result5}
        }
    )
in
    summary

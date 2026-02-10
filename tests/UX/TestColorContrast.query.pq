let
    // Load the function from file
    TestColorContrast = Expression.Evaluate(Text.FromBinary(File.Contents("functions/UX/TestColorContrast.pq")), #shared),
    
    // Test 1: Validate function is callable (type check)
    test1 = Value.Type(TestColorContrast),
    result1 = if Type.Is(test1, type function) then "Test 1 Passed" else "Test 1 Failed",
    
    // Test 2: Test white vs black (maximum contrast - should pass)
    test2 = TestColorContrast("#FFFFFF", "#000000"),
    result2 = if test2 = "Enough Contrast" then "Test 2 Passed" else "Test 2 Failed",
    
    // Test 3: Test two similar reds (insufficient contrast - should fail)
    test3 = TestColorContrast("#FF0000", "#FE0000"),
    result3 = if test3 = "Not Enough Contrast" then "Test 3 Passed" else "Test 3 Failed",
    
    // Test 4: Test blue vs white (should have enough contrast)
    test4 = TestColorContrast("#0000FF", "#FFFFFF"),
    result4 = if test4 = "Enough Contrast" then "Test 4 Passed" else "Test 4 Failed",
    
    // Test 5: Test gray vs dark gray (borderline contrast)
    test5 = TestColorContrast("#767676", "#FFFFFF"),
    result5 = if test5 <> null then "Test 5 Passed" else "Test 5 Failed",
    
    // Test 6: Test with custom culture parameter
    test6 = TestColorContrast("#FFFF00", "#000000", "en-GB"),
    result6 = if test6 = "Enough Contrast" then "Test 6 Passed" else "Test 6 Failed",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Function is callable", result1},
            {"Test 2: White vs Black (enough contrast)", result2},
            {"Test 3: Similar reds (not enough)", result3},
            {"Test 4: Blue vs White (enough)", result4},
            {"Test 5: Gray vs White (returns result)", result5},
            {"Test 6: Yellow vs Black with culture", result6}
        }
    )
in
    summary

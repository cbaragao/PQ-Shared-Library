let
    // Load the function from file
    GetColorHue = Expression.Evaluate(Text.FromBinary(File.Contents("functions/UX/GetColorHue.pq")), #shared),
    
    // Test 1: Validate function is callable (type check)
    test1 = Value.Type(GetColorHue),
    result1 = if Type.Is(test1, type function) then "Test 1 Passed" else "Test 1 Failed",
    
    // Test 2: Test with orange-red color
    test2 = GetColorHue("#FF5733"),
    result2 = if test2 > 10 and test2 < 11 then "Test 2 Passed" else "Test 2 Failed: " & Text.From(test2, "en-US"),
    
    // Test 3: Test with pure green
    test3 = GetColorHue("#00FF00"),
    result3 = if test3 > 119 and test3 < 121 then "Test 3 Passed" else "Test 3 Failed: " & Text.From(test3, "en-US"),
    
    // Test 4: Test with pure blue
    test4 = GetColorHue("#0000FF"),
    result4 = if test4 > 239 and test4 < 241 then "Test 4 Passed" else "Test 4 Failed: " & Text.From(test4, "en-US"),
    
    // Test 5: Test with custom culture parameter
    test5 = GetColorHue("#FFFF00", "en-GB"),
    result5 = if test5 > 59 and test5 < 61 then "Test 5 Passed" else "Test 5 Failed",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Function is callable", result1},
            {"Test 2: Orange-red hue (~10.59°)", result2},
            {"Test 3: Pure green hue (~120°)", result3},
            {"Test 4: Pure blue hue (~240°)", result4},
            {"Test 5: Yellow with custom culture", result5}
        }
    )
in
    summary

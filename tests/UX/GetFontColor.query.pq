let
    // Load the function from file
    GetFontColor = Expression.Evaluate(Text.FromBinary(File.Contents("functions/UX/GetFontColor.pq")), #shared),
    
    // Test 1: Original example - medium-dark background #666A86
    test1 = GetFontColor("#666A86"),
    result1 = if test1 = "#000000" then "Test 1 Passed" else "Test 1 Failed: Got " & test1,
    
    // Test 2: Dutch White (light background) -> should use black text
    test2 = GetFontColor("#E8DDB5"),
    result2 = if test2 = "#000000" then "Test 2 Passed" else "Test 2 Failed: Got " & test2,
    
    // Test 3: Pure black background -> white text
    test3 = GetFontColor("#000000"),
    result3 = if test3 = "#FFFFFF" then "Test 3 Passed" else "Test 3 Failed: Got " & test3,
    
    // Test 4: Pure white background -> black text
    test4 = GetFontColor("#FFFFFF"),
    result4 = if test4 = "#000000" then "Test 4 Passed" else "Test 4 Failed: Got " & test4,
    
    // Test 5: Dark navy (#17224A) -> white text
    test5 = GetFontColor("#17224A"),
    result5 = if test5 = "#FFFFFF" then "Test 5 Passed" else "Test 5 Failed: Got " & test5,
    
    // Test 6: Medium gray (#808080) -> threshold test
    test6 = GetFontColor("#808080"),
    result6 = if test6 = "#000000" then "Test 6 Passed" else "Test 6 Failed: Got " & test6,
    
    // Test 7: Lowercase hex input
    test7 = GetFontColor("#666a86"),
    result7 = if test7 = "#000000" then "Test 7 Passed" else "Test 7 Failed: Got " & test7,
    
    // Test 8: With custom culture
    test8 = GetFontColor("#666A86", "en-US"),
    result8 = if test8 = "#000000" then "Test 8 Passed" else "Test 8 Failed: Got " & test8,
    
    // Test 9: Structural test - verify parameter count
    metadata = Value.Metadata(Value.Type(GetFontColor)),
    params = Type.FunctionParameters(Value.Type(GetFontColor)),
    paramCount = Record.FieldCount(params),
    result9 = if paramCount = 2 then "Test 9 Passed" else "Test 9 Failed: Expected 2 parameters, got " & Number.ToText(paramCount),
    
    // Test 10: Verify parameter names
    paramNames = Record.FieldNames(params),
    hasHEX = List.Contains(paramNames, "HEX"),
    hasCulture = List.Contains(paramNames, "culture"),
    result10 = if hasHEX and hasCulture then "Test 10 Passed" else "Test 10 Failed: Missing expected parameters",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Medium-dark background (#666A86)", result1},
            {"Test 2: Light background (#E8DDB5)", result2},
            {"Test 3: Pure black -> white text", result3},
            {"Test 4: Pure white -> black text", result4},
            {"Test 5: Dark navy (#17224A) -> white text", result5},
            {"Test 6: Medium gray threshold test", result6},
            {"Test 7: Lowercase hex input", result7},
            {"Test 8: Custom culture parameter", result8},
            {"Test 9: Parameter count", result9},
            {"Test 10: Parameter names", result10}
        }
    )
in
    summary

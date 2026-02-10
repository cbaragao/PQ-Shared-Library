let
    // Load the function from file
    GetHexValue = Expression.Evaluate(Text.FromBinary(File.Contents("functions/UX/GetHexValue.pq")), #shared),
    
    // Test 1: Original example - pure white
    test1 = GetHexValue(255, 255, 255),
    result1 = if test1 = "#FFFFFF" then "Test 1 Passed" else "Test 1 Failed: Got " & test1,
    
    // Test 2: Pure red
    test2 = GetHexValue(255, 0, 0),
    result2 = if test2 = "#FF0000" then "Test 2 Passed" else "Test 2 Failed: Got " & test2,
    
    // Test 3: Pure green
    test3 = GetHexValue(0, 255, 0),
    result3 = if test3 = "#00FF00" then "Test 3 Passed" else "Test 3 Failed: Got " & test3,
    
    // Test 4: Pure blue
    test4 = GetHexValue(0, 0, 255),
    result4 = if test4 = "#0000FF" then "Test 4 Passed" else "Test 4 Failed: Got " & test4,
    
    // Test 5: Pure black
    test5 = GetHexValue(0, 0, 0),
    result5 = if test5 = "#000000" then "Test 5 Passed" else "Test 5 Failed: Got " & test5,
    
    // Test 6: Dutch white (232, 221, 181)
    test6 = GetHexValue(232, 221, 181),
    result6 = if test6 = "#E8DDB5" then "Test 6 Passed" else "Test 6 Failed: Got " & test6,
    
    // Test 7: Medium gray (128, 128, 128)
    test7 = GetHexValue(128, 128, 128),
    result7 = if test7 = "#808080" then "Test 7 Passed" else "Test 7 Failed: Got " & test7,
    
    // Test 8: With custom culture parameter
    test8 = GetHexValue(255, 255, 255, "en-US"),
    result8 = if test8 = "#FFFFFF" then "Test 8 Passed" else "Test 8 Failed: Got " & test8,
    
    // Test 9: Low values (10, 15, 20) - tests single digit hex conversion
    test9 = GetHexValue(10, 15, 20),
    result9 = if test9 = "#0A0F14" then "Test 9 Passed" else "Test 9 Failed: Got " & test9,
    
    // Test 10: Structural test - verify parameter count
    metadata = Value.Metadata(Value.Type(GetHexValue)),
    params = Type.FunctionParameters(Value.Type(GetHexValue)),
    paramCount = Record.FieldCount(params),
    result10 = if paramCount = 4 then "Test 10 Passed" else "Test 10 Failed: Expected 4 parameters, got " & Number.ToText(paramCount),
    
    // Test 11: Verify parameter names
    paramNames = Record.FieldNames(params),
    hasRed = List.Contains(paramNames, "red"),
    hasGreen = List.Contains(paramNames, "green"),
    hasBlue = List.Contains(paramNames, "blue"),
    hasCulture = List.Contains(paramNames, "culture"),
    result11 = if hasRed and hasGreen and hasBlue and hasCulture then "Test 11 Passed" else "Test 11 Failed: Missing expected parameters",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Pure white (255,255,255)", result1},
            {"Test 2: Pure red (255,0,0)", result2},
            {"Test 3: Pure green (0,255,0)", result3},
            {"Test 4: Pure blue (0,0,255)", result4},
            {"Test 5: Pure black (0,0,0)", result5},
            {"Test 6: Dutch white (232,221,181)", result6},
            {"Test 7: Medium gray (128,128,128)", result7},
            {"Test 8: Custom culture parameter", result8},
            {"Test 9: Low values single digit hex", result9},
            {"Test 10: Parameter count", result10},
            {"Test 11: Parameter names", result11}
        }
    )
in
    summary

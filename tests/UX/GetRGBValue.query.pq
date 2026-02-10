let
    // Define the function directly in the test file
    GetRGBValue = (HEX as text, optional culture as nullable text) as text =>
    let 
      // Use default culture if not provided
      cultureToUse = culture ?? "en-US",
      
      // Split strings into list by each character, convert to upper, remove hash
      Source = if HEX <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX, cultureToUse), "#", 0)) else "#000000",
      
      // Split the Source by each character
      SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

      GetColor = (hexlist as list) as text =>
        let 
          // Build the RGB list
          RGB = List.Combine({{"0".."9"}, {"A".."F"}}),
          
          // Sub function to convert hex digit pair to RGB value (0-255 range)
          GetRGB = (cval1 as number, cval2 as number) as number =>
            let 
              RGBVal = (Number.From(cval1) * 16) + Number.From(cval2)
            in       
              RGBVal,
          
          // Get positions of each digit
          r = GetRGB(List.PositionOf(RGB, hexlist{0}), List.PositionOf(RGB, hexlist{1})),
          g = GetRGB(List.PositionOf(RGB, hexlist{2}), List.PositionOf(RGB, hexlist{3})),
          b = GetRGB(List.PositionOf(RGB, hexlist{4}), List.PositionOf(RGB, hexlist{5})),

          // Combine R, G, B values to comma-separated text (e.g., "255,0,128")
          FinalRGB = Text.Combine({Text.From(r, cultureToUse), Text.From(g, cultureToUse), Text.From(b, cultureToUse)}, ",")
        in
          FinalRGB,
      
      // Process the split list from the input
      RGBValues = GetColor(SplitHex)
    in
      RGBValues,
    
    // Test 1: Original example - pure white
    test1 = GetRGBValue("#FFFFFF"),
    result1 = if test1 = "255,255,255" then "Test 1 Passed" else "Test 1 Failed: Got " & test1,
    
    // Test 2: Pure red
    test2 = GetRGBValue("#FF0000"),
    result2 = if test2 = "255,0,0" then "Test 2 Passed" else "Test 2 Failed: Got " & test2,
    
    // Test 3: Pure green
    test3 = GetRGBValue("#00FF00"),
    result3 = if test3 = "0,255,0" then "Test 3 Passed" else "Test 3 Failed: Got " & test3,
    
    // Test 4: Pure blue
    test4 = GetRGBValue("#0000FF"),
    result4 = if test4 = "0,0,255" then "Test 4 Passed" else "Test 4 Failed: Got " & test4,
    
    // Test 5: Pure black
    test5 = GetRGBValue("#000000"),
    result5 = if test5 = "0,0,0" then "Test 5 Passed" else "Test 5 Failed: Got " & test5,
    
    // Test 6: Dutch white (232, 221, 181)
    test6 = GetRGBValue("#E8DDB5"),
    result6 = if test6 = "232,221,181" then "Test 6 Passed" else "Test 6 Failed: Got " & test6,
    
    // Test 7: Medium gray (128, 128, 128)
    test7 = GetRGBValue("#808080"),
    result7 = if test7 = "128,128,128" then "Test 7 Passed" else "Test 7 Failed: Got " & test7,
    
    // Test 8: Bright orange #FF5733
    test8 = GetRGBValue("#FF5733"),
    result8 = if test8 = "255,87,51" then "Test 8 Passed" else "Test 8 Failed: Got " & test8,
    
    // Test 9: Lowercase hex input
    test9 = GetRGBValue("#ffffff"),
    result9 = if test9 = "255,255,255" then "Test 9 Passed" else "Test 9 Failed: Got " & test9,
    
    // Test 10: With custom culture parameter
    test10 = GetRGBValue("#FFFFFF", "en-US"),
    result10 = if test10 = "255,255,255" then "Test 10 Passed" else "Test 10 Failed: Got " & test10,
    
    // Test 11: Low values (10, 15, 20) from #0A0F14
    test11 = GetRGBValue("#0A0F14"),
    result11 = if test11 = "10,15,20" then "Test 11 Passed" else "Test 11 Failed: Got " & test11,
    
    // Test 12: Structural test - verify parameter count
    metadata = Value.Metadata(Value.Type(GetRGBValue)),
    params = Type.FunctionParameters(Value.Type(GetRGBValue)),
    paramCount = Record.FieldCount(params),
    result12 = if paramCount = 2 then "Test 12 Passed" else "Test 12 Failed: Expected 2 parameters, got " & Number.ToText(paramCount),
    
    // Test 13: Verify parameter names
    paramNames = Record.FieldNames(params),
    hasHEX = List.Contains(paramNames, "HEX"),
    hasCulture = List.Contains(paramNames, "culture"),
    result13 = if hasHEX and hasCulture then "Test 13 Passed" else "Test 13 Failed: Missing expected parameters",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Pure white (#FFFFFF)", result1},
            {"Test 2: Pure red (#FF0000)", result2},
            {"Test 3: Pure green (#00FF00)", result3},
            {"Test 4: Pure blue (#0000FF)", result4},
            {"Test 5: Pure black (#000000)", result5},
            {"Test 6: Dutch white (#E8DDB5)", result6},
            {"Test 7: Medium gray (#808080)", result7},
            {"Test 8: Bright orange (#FF5733)", result8},
            {"Test 9: Lowercase hex input", result9},
            {"Test 10: Custom culture parameter", result10},
            {"Test 11: Low values from #0A0F14", result11},
            {"Test 12: Parameter count", result12},
            {"Test 13: Parameter names", result13}
        }
    )
in
    summary

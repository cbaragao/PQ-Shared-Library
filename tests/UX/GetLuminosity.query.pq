let
    // Define the function directly in the test file
    GetLuminosity = (HEX as text, optional culture as nullable text) as number =>
      let
        // Use default culture if not provided
        cultureToUse = culture ?? "en-US",
        
        // Split strings into list by each character, convert to upper, remove hash
        Source = if HEX <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX, cultureToUse), "#", 0)) else "#000000",
        
        // Split the Source by each character
        SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

        GetLuminosityInternal = (hexlist as list) as number =>
          let 
            // Build the RGB list
            RGB = List.Combine({{"0".."9"},{"A".."F"}}),
            
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
            
            // Combine R, G, B values into a list
            FinalRGB = {r, g, b},
            
            // Calculate luminosity using HSL lightness formula
            // Luminosity = (max(R,G,B) + min(R,G,B)) / 2 / 255
            // Returns value in 0-1 range where 0=black, 0.5=pure color, 1=white
            Luminosity = 0.5 * (List.Max(FinalRGB) / 255 + List.Min(FinalRGB) / 255)
          in
            Luminosity,
        
        // Process the split list from the input
        lum = GetLuminosityInternal(SplitHex)
      in
        lum,
    
    // Test 1: Original example - bright orange #FF5733
    test1 = GetLuminosity("#FF5733"),
    result1 = if test1 = 0.6 then "Test 1 Passed" else "Test 1 Failed: Got " & Number.ToText(test1),
    
    // Test 2: Medium gray #808080 - should be 0.5
    test2 = GetLuminosity("#808080"),
    result2 = if test2 = 0.5 then "Test 2 Passed" else "Test 2 Failed: Got " & Number.ToText(test2),
    
    // Test 3: Pure black #000000 - should be 0
    test3 = GetLuminosity("#000000"),
    result3 = if test3 = 0 then "Test 3 Passed" else "Test 3 Failed: Got " & Number.ToText(test3),
    
    // Test 4: Pure white #FFFFFF - should be 1
    test4 = GetLuminosity("#FFFFFF"),
    result4 = if test4 = 1 then "Test 4 Passed" else "Test 4 Failed: Got " & Number.ToText(test4),
    
    // Test 5: Pure red #FF0000 - max=255, min=0, luminosity=0.5
    test5 = GetLuminosity("#FF0000"),
    result5 = if test5 = 0.5 then "Test 5 Passed" else "Test 5 Failed: Got " & Number.ToText(test5),
    
    // Test 6: Pure green #00FF00 - max=255, min=0, luminosity=0.5
    test6 = GetLuminosity("#00FF00"),
    result6 = if test6 = 0.5 then "Test 6 Passed" else "Test 6 Failed: Got " & Number.ToText(test6),
    
    // Test 7: Pure blue #0000FF - max=255, min=0, luminosity=0.5
    test7 = GetLuminosity("#0000FF"),
    result7 = if test7 = 0.5 then "Test 7 Passed" else "Test 7 Failed: Got " & Number.ToText(test7),
    
    // Test 8: Dutch white #E8DDB5 (232, 221, 181) - max=232, min=181, luminosity≈0.81
    test8 = GetLuminosity("#E8DDB5"),
    expectedLum8 = 0.5 * (232 / 255 + 181 / 255),
    result8 = if Number.Round(test8, 4) = Number.Round(expectedLum8, 4) then "Test 8 Passed" else "Test 8 Failed: Got " & Number.ToText(test8),
    
    // Test 9: Lowercase hex input
    test9 = GetLuminosity("#ff5733"),
    result9 = if test9 = 0.6 then "Test 9 Passed" else "Test 9 Failed: Got " & Number.ToText(test9),
    
    // Test 10: With custom culture parameter
    test10 = GetLuminosity("#FF5733", "en-US"),
    result10 = if test10 = 0.6 then "Test 10 Passed" else "Test 10 Failed: Got " & Number.ToText(test10),
    
    // Test 11: Structural test - verify parameter count
    metadata = Value.Metadata(Value.Type(GetLuminosity)),
    params = Type.FunctionParameters(Value.Type(GetLuminosity)),
    paramCount = Record.FieldCount(params),
    result11 = if paramCount = 2 then "Test 11 Passed" else "Test 11 Failed: Expected 2 parameters, got " & Number.ToText(paramCount),
    
    // Test 12: Verify parameter names
    paramNames = Record.FieldNames(params),
    hasHEX = List.Contains(paramNames, "HEX"),
    hasCulture = List.Contains(paramNames, "culture"),
    result12 = if hasHEX and hasCulture then "Test 12 Passed" else "Test 12 Failed: Missing expected parameters",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Bright orange (#FF5733)", result1},
            {"Test 2: Medium gray (#808080)", result2},
            {"Test 3: Pure black = 0", result3},
            {"Test 4: Pure white = 1", result4},
            {"Test 5: Pure red = 0.5", result5},
            {"Test 6: Pure green = 0.5", result6},
            {"Test 7: Pure blue = 0.5", result7},
            {"Test 8: Dutch white luminosity", result8},
            {"Test 9: Lowercase hex input", result9},
            {"Test 10: Custom culture parameter", result10},
            {"Test 11: Parameter count", result11},
            {"Test 12: Parameter names", result12}
        }
    )
in
    summary

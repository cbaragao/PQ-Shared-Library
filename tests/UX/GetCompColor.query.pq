let
    // Define the function directly in the test file
    GetCompColor = (HEX as text, optional culture as nullable text) as text =>
      let
        // Use default culture if not provided
        cultureToUse = culture ?? "en-US",
        
        // Split strings into list by each character, convert to upper, remove hash
        Source = if HEX <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX, cultureToUse), "#", 0)) else "#000000",
        
        // Split the Source by each character
        SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

        // Function to calculate complementary color
        GetCompColorInternal = (hexlist as list) as text =>
          let 
            // Build the RGB list
            RGB = List.Combine({{"0".."9"},{"A".."F"}}),
            
            // Sub function to figure out complementary color RGB value
            GetCompRGB = (cval1 as number, cval2 as number) as number =>
              let 
                RGBVal = 255 - ((cval1 * 16) + cval2)
              in       
                RGBVal,
            
            // Sub function to figure out complementary color hex value
            ConvertToHex = (val as number) as text =>
              let 
                first_digit = Number.IntegerDivide(val, 16),
                second_digit = Number.Mod(val, 16),
                both_hex = Text.Combine({RGB{first_digit}, RGB{second_digit}})
              in    
                both_hex,
            
            // Get positions of each digit
            r1 = List.PositionOf(RGB, hexlist{0}),
            r2 = List.PositionOf(RGB, hexlist{1}),
            g1 = List.PositionOf(RGB, hexlist{2}),
            g2 = List.PositionOf(RGB, hexlist{3}),
            b1 = List.PositionOf(RGB, hexlist{4}),
            b2 = List.PositionOf(RGB, hexlist{5}),

            // Process digit values 
            cred = GetCompRGB(r1, r2),
            cgreen = GetCompRGB(g1, g2),
            cblue = GetCompRGB(b1, b2),
            
            // Combine R, G, B hex values to one hex value
            FinalRGB = Text.Combine({
              "#",
              ConvertToHex(cred),
              ConvertToHex(cgreen),
              ConvertToHex(cblue)
            })
          in
            FinalRGB,
    
        // Process the split list from the input
        CompColor = GetCompColorInternal(SplitHex)
      in
        CompColor,
    
    // Test 1: Original example - Dutch White
    test1 = GetCompColor("#E8DDB5"),
    result1 = if test1 = "#17224A" then "Test 1 Passed" else "Test 1 Failed: Got " & test1,
    
    // Test 2: Pure red -> cyan
    test2 = GetCompColor("#FF0000"),
    result2 = if test2 = "#00FFFF" then "Test 2 Passed" else "Test 2 Failed: Got " & test2,
    
    // Test 3: Pure green -> magenta
    test3 = GetCompColor("#00FF00"),
    result3 = if test3 = "#FF00FF" then "Test 3 Passed" else "Test 3 Failed: Got " & test3,
    
    // Test 4: Pure blue -> yellow
    test4 = GetCompColor("#0000FF"),
    result4 = if test4 = "#FFFF00" then "Test 4 Passed" else "Test 4 Failed: Got " & test4,
    
    // Test 5: Black -> white
    test5 = GetCompColor("#000000"),
    result5 = if test5 = "#FFFFFF" then "Test 5 Passed" else "Test 5 Failed: Got " & test5,
    
    // Test 6: White -> black
    test6 = GetCompColor("#FFFFFF"),
    result6 = if test6 = "#000000" then "Test 6 Passed" else "Test 6 Failed: Got " & test6,
    
    // Test 7: Lowercase hex input
    test7 = GetCompColor("#ff0000"),
    result7 = if test7 = "#00FFFF" then "Test 7 Passed" else "Test 7 Failed: Got " & test7,
    
    // Test 8: With custom culture
    test8 = GetCompColor("#E8DDB5", "en-US"),
    result8 = if test8 = "#17224A" then "Test 8 Passed" else "Test 8 Failed: Got " & test8,
    
    // Test 9: Structural test - verify parameter count
    metadata = Value.Metadata(Value.Type(GetCompColor)),
    params = Type.FunctionParameters(Value.Type(GetCompColor)),
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
            {"Test 1: Dutch White (#E8DDB5)", result1},
            {"Test 2: Pure red -> cyan", result2},
            {"Test 3: Pure green -> magenta", result3},
            {"Test 4: Pure blue -> yellow", result4},
            {"Test 5: Black -> white", result5},
            {"Test 6: White -> black", result6},
            {"Test 7: Lowercase hex input", result7},
            {"Test 8: Custom culture parameter", result8},
            {"Test 9: Parameter count", result9},
            {"Test 10: Parameter names", result10}
        }
    )
in
    summary

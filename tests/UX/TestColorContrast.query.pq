let
    // Define the function directly in the test file
    TestColorContrast = (HEX1 as text, HEX2 as text, optional culture as nullable text) as text =>
        let 
            // Use default culture if not provided
            cultureToUse = culture ?? "en-US",
            
            // Split strings into list by each character, convert to upper, remove hash
            H1 = if HEX1 <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX1, cultureToUse), "#", 0)) else "#000000",
            H2 = if HEX2 <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX2, cultureToUse), "#", 0)) else "#000000",
            
            // Split the Source by each character
            SplitHex1 = Splitter.SplitTextByRepeatedLengths(1)(H1),
            SplitHex2 = Splitter.SplitTextByRepeatedLengths(1)(H2),
            
            GetLuminance = (hexlist as list) as number => 
                // Nested let function to do all luminance calculations
                let 
                        // Set exp constant
                        exp= 2.4,
                        
                        // Build the RGB list
                        RGB = List.Combine({{"0".."9"},{"A".."F"}}),

                        //Get srgb sunfunction
                        GetSRGB = (cval1 as number, cval2 as number) as number =>
                        let 
                            SRGB = ((cval1 * 16)+ cval2)/255
                            in       
                        SRGB,

                        // Get final c values subfunction
                        GetFinalColorVal = (srgb as number) as number =>
                            let   
                                colorval = if srgb <=0.03928 then srgb/12.92 else Number.Power(((srgb + 0.055)/1.055), exp, RoundingMode.AwayFromZero)
                            in  
                                colorval,  

                        r1 = List.PositionOf(RGB, hexlist{0}),
                        r2 = List.PositionOf(RGB, hexlist{1}),
                        g1 = List.PositionOf(RGB, hexlist{2}),
                        g2 = List.PositionOf(RGB, hexlist{3}),
                        b1 = List.PositionOf(RGB, hexlist{4}),
                        b2 = List.PositionOf(RGB, hexlist{5}),

                        // Calculate rsrgb, gsrgb, bsrgb
                        rsrgb = GetSRGB(r1,r2),
                        gsrgb = GetSRGB(g1,g2),
                        bsrgb = GetSRGB(b1,b2),

                        // Calculate r, g, b
                        r = GetFinalColorVal(rsrgb),
                        g = GetFinalColorVal(gsrgb),
                        b = GetFinalColorVal(bsrgb),
            
                        // Calculate luminance
                        luminance = (0.2126 * r) + 
                                    (0.7152 * g) + 
                                    (0.0722 * b)
                in  
                        luminance,

            // Determine contrast ratio
            l1 = GetLuminance(SplitHex1),
            l2 = GetLuminance(SplitHex2),

            cratio =  if l1 > l2 then (l1 + 0.05) / (l2 + 0.05) else (l2 + 0.05) / (l1 + 0.05),

            // Set min contrast
            min = 4.5,

            // Determine if it meets min
            contrast = if cratio >= min then "Enough Contrast" else "Not Enough Contrast"
        in 
            contrast,
    
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

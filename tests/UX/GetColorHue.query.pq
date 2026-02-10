let
    // Define the function directly in the test file
    GetColorHue = (HEX as text, optional culture as nullable text) as number =>
        let
          // Use default culture if not provided
          cultureToUse = culture ?? "en-US",
          
          // Split strings into list by each character, convert to upper, remove hash
          Source = if HEX <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX, cultureToUse), "#", 0)) else "#000000",
          
          // Split the Source by each character
          SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

          GetHue = (hexlist as list) as number =>
            let 
              // Build the RGB list
              RGB = List.Combine({{"0".."9"},{"A".."F"}}),
              
              // Sub function to figure out RGB value
              GetRGB = (cval1 as number, cval2 as number) as number =>
                let 
                  RGBVal = (Number.From(cval1, cultureToUse) * 16) + Number.From(cval2, cultureToUse)
                in       
                  RGBVal,
              
              // Get positions of each digit
              r = GetRGB(List.PositionOf(RGB, hexlist{0}), List.PositionOf(RGB, hexlist{1})),
              g = GetRGB(List.PositionOf(RGB, hexlist{2}), List.PositionOf(RGB, hexlist{3})),
              b = GetRGB(List.PositionOf(RGB, hexlist{4}), List.PositionOf(RGB, hexlist{5})),
              
              // Get the hue from r, g, b values
              hue = 
                if r >= g and g >= b then 60 * (g - b) / (r - b)
                else if g > r and r >= b then 60 * (2 - (r - b) / (g - b))
                else if g >= b and b > r then 60 * (2 + (b - r) / (g - r))
                else if b > g and g > r then 60 * (4 - (g - r) / (b - r))
                else if b > r and r >= g then 60 * (4 + (r - g) / (b - g))
                else if r >= b and b > g then 60 * (6 - (b - g) / (r - g))
                else -1
            in
              hue,
          
          // Process the split list from the input
          Result = GetHue(SplitHex)
        in
          Result,
    
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

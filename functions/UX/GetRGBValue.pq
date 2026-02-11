let 
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
    
  fnType = type function (HEX as text, optional culture as nullable text) as text
    meta [
      Documentation.Name = "Get-RGBValue",
      Documentation.LongDescription = "Converts a hexadecimal color code (#RRGGBB format) to comma-separated RGB values (0-255 range). Each hex digit pair is converted to its decimal equivalent: the first digit is multiplied by 16 and added to the second digit. Returns a text string in the format 'R,G,B' (e.g., '255,128,0'). This is the inverse operation of GetHexValue.",
      Documentation.Examples = {
        [
          Description = "Convert pure white hex code to RGB values.",
          Code = "GetRGBValue(""#FFFFFF"")",
          Result = "255,255,255"
        ],
        [
          Description = "Convert pure red hex code to RGB values.",
          Code = "GetRGBValue(""#FF0000"")",
          Result = "255,0,0"
        ],
        [
          Description = "Convert dutch white hex code to RGB values.",
          Code = "GetRGBValue(""#E8DDB5"")",
          Result = "232,221,181"
        ]
      }
    ] 
in  
  Value.ReplaceType(GetRGBValue, fnType)
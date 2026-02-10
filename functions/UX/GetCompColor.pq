let
  // Define the function using simplified syntax
  GetCompColor = (HEX as text, optional culture as nullable text) as text =>
      let
        // Use default culture if not provided
        cultureToUse = culture ?? "en-US",
        
        // Split strings into list by each character, convert to upper, remove hash
        Source = if HEX <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX, cultureToUse), "#", 0, Comparer.Ordinal)) else "#000000",
        
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
                first_digit = Number.RoundDown(val / 16, RoundingMode.Down),
                second_digit = ((val / 16) - Number.RoundDown(val / 16, RoundingMode.Down)) * 16,
                both_hex = Text.Combine({RGB{first_digit}, RGB{second_digit}})
              in    
                both_hex,
            
            // Get positions of each digit
            r1 = List.PositionOf(RGB, hexlist{0}, Occurrence.First, Comparer.Ordinal),
            r2 = List.PositionOf(RGB, hexlist{1}, Occurrence.First, Comparer.Ordinal),
            g1 = List.PositionOf(RGB, hexlist{2}, Occurrence.First, Comparer.Ordinal),
            g2 = List.PositionOf(RGB, hexlist{3}, Occurrence.First, Comparer.Ordinal),
            b1 = List.PositionOf(RGB, hexlist{4}, Occurrence.First, Comparer.Ordinal),
            b2 = List.PositionOf(RGB, hexlist{5}, Occurrence.First, Comparer.Ordinal),

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

  // Define the function type with metadata
  fnType = type function (HEX as text, optional culture as nullable text) as text
    meta [
      Documentation.Name = "Get-CompColor",
      Documentation.LongDescription = "Calculates the complementary (opposite) color for a given hex color code. The complementary color is found by inverting the RGB values (255 - R, 255 - G, 255 - B), which produces a color that is opposite on the color wheel. Complementary colors create high contrast and are commonly used in design for visual impact.",
      Documentation.Examples = {
        [
          Description = "Get the complementary color for dutch white (#E8DDB5).",
          Code        = "GetCompColor(""#E8DDB5"")",
          Result      = "#17224A"
        ],
        [
          Description = "Get the complementary color for pure red.",
          Code        = "GetCompColor(""#FF0000"")",
          Result      = "#00FFFF (cyan)"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetCompColor, fnType)
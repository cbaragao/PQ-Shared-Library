let
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
        
  fnType = type function (HEX as text, optional culture as nullable text) as number
    meta [
      Documentation.Name = "Get-ColorHue", 
      Documentation.LongDescription = "Calculates the hue value (0-360 degrees) of a color from its hexadecimal code. The hue represents the position on the color wheel, where red is around 0°, green is around 120°, and blue is around 240°. This is the H component in HSL (Hue, Saturation, Lightness) color space.", 
      Documentation.Examples = {
        [
          Description = "Calculate the hue of an orange-red color.",
          Code        = "GetColorHue(""#FF5733"")", 
          Result      = "10.588235294117647"
        ],
        [
          Description = "Calculate the hue of pure red.",
          Code        = "GetColorHue(""#FF0000"")", 
          Result      = "0 (or -1 if achromatic)"
        ]
      }
    ]
in
  Value.ReplaceType(GetColorHue, fnType)

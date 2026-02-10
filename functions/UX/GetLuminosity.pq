let
  GetLuminosity = (HEX as text, optional culture as nullable text) as number =>
      let
        // Use default culture if not provided
        cultureToUse = culture ?? "en-US",
        
        // Split strings into list by each character, convert to upper, remove hash
        Source = if HEX <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX, cultureToUse), "#", 0, Comparer.Ordinal)) else "#000000",
        
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
            r = GetRGB(List.PositionOf(RGB, hexlist{0}, Occurrence.First, Comparer.Ordinal), List.PositionOf(RGB, hexlist{1}, Occurrence.First, Comparer.Ordinal)),
            g = GetRGB(List.PositionOf(RGB, hexlist{2}, Occurrence.First, Comparer.Ordinal), List.PositionOf(RGB, hexlist{3}, Occurrence.First, Comparer.Ordinal)),
            b = GetRGB(List.PositionOf(RGB, hexlist{4}, Occurrence.First, Comparer.Ordinal), List.PositionOf(RGB, hexlist{5}, Occurrence.First, Comparer.Ordinal)),
            
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
  fnType = type function (HEX as text, optional culture as nullable text) as number
    meta [
      Documentation.Name = "Get-Luminosity", 
      Documentation.LongDescription = "Calculates the luminosity (lightness) of a color from its hex code using the HSL color model. Luminosity is calculated as the average of the maximum and minimum RGB values: L = (max(R,G,B) + min(R,G,B)) / 2 / 255. The result ranges from 0 (black) to 1 (white), with 0.5 representing pure saturated colors. This is different from perceived brightness (luminance) which uses weighted sRGB coefficients.", 
      Documentation.Examples = {
        [
          Description = "Calculate the luminosity of a bright orange color (#FF5733).",
          Code        = "GetLuminosity(""#FF5733"")", 
          Result      = "0.6 (relatively bright)"
        ],
        [
          Description = "Calculate the luminosity of medium gray (#808080).",
          Code        = "GetLuminosity(""#808080"")", 
          Result      = "0.5 (medium lightness)"
        ]
      }
    ]
in
  Value.ReplaceType(GetLuminosity, fnType)

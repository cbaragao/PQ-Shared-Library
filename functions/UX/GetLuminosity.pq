let
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
  fnType = type function (HEX as text, optional culture as nullable text) as number
    meta [
      Documentation.Name = "Get-Luminosity", 
      Documentation.LongDescription = "Calculates the luminosity (lightness) of a color from its hex code using the HSL color model. Luminosity is calculated as the average of the maximum and minimum RGB values: L = (max(R,G,B) + min(R,G,B)) / 2 / 255. The result ranges from 0 (black) to 1 (white), with 0.5 representing pure saturated colors and most grays. This is different from perceived brightness (luminance), which uses weighted sRGB coefficients. For example, #FF5733 (bright orange) yields 0.6, #808080 (medium gray) yields approximately 0.502, and #000000/#FFFFFF yield 0 and 1, respectively.",
      Documentation.Examples = {
        [
          Description = "Calculate the luminosity of a bright orange color (#FF5733).",
          Code        = "GetLuminosity(\"#FF5733\")", 
          Result      = "0.6 (relatively bright)"
        ],
        [
          Description = "Calculate the luminosity of medium gray (#808080).",
          Code        = "GetLuminosity(\"#808080\")", 
          Result      = "≈0.502 (medium gray)"
        ],
        [
          Description = "Calculate the luminosity of pure black (#000000).",
          Code        = "GetLuminosity(\"#000000\")", 
          Result      = "0 (black)"
        ],
        [
          Description = "Calculate the luminosity of pure white (#FFFFFF).",
          Code        = "GetLuminosity(\"#FFFFFF\")", 
          Result      = "1 (white)"
        ]
      }
    ]
in
  Value.ReplaceType(GetLuminosity, fnType)

let
  GetLuminosity = Function.From(
    type function (HEX as text) as number, 
    (params) =>
      let
        // Split strings into list by each character, convert to upper, remove hash
        Source = if params{0} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{0}), "#")) else "#000000",
        
        // Split the Source by each character
        SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

        GetLuminosity = (hexlist) =>
          let 
            // Build the RGB list
            RGB = List.Combine({{"0".."9"},{"A".."F"}}),
            
            // Sub function to figure out complimentary color RGB value
            GetRGB = (cval1, cval2) =>
              let 
                RGBVal = (Number.From(cval1) * 16) + Number.From(cval2)
              in       
                RGBVal,
            
            // Get positions of each digit
            r = GetRGB(List.PositionOf(RGB, hexlist{0}), List.PositionOf(RGB, hexlist{1})),
            g = GetRGB(List.PositionOf(RGB, hexlist{2}), List.PositionOf(RGB, hexlist{3})),
            b = GetRGB(List.PositionOf(RGB, hexlist{4}), List.PositionOf(RGB, hexlist{5})),
            
            // Combine R, G, B hex values to one hex value
            FinalRGB = {r, g, b},
            
            // Get the luminosity
            Luminosity = 0.5 * (List.Max(FinalRGB) / 255 + List.Min(FinalRGB) / 255)
          in
            Luminosity,
        
        // Process the split list from the input
        lum = GetLuminosity(SplitHex)
      in
        lum
  ), 
  fnType = type function (HEX as text) as number
    meta [
      Documentation.Name = "GetLuminosity", 
      Documentation.LongDescription = "This function calculates the luminosity of a color given its HEX code.", 
      Documentation.Examples = {
        [
          Description = "Calculate the luminosity of a color given its HEX code.",
          Code        = "=GetLuminosity(""#FF5733"")", 
          Result      = "0.6"
        ]
      }
    ]
in
  Value.ReplaceType(GetLuminosity, fnType)

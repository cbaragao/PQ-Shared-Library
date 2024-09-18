let
  GetColorHue = Function.From(
    type function (HEX as text) as number, 
    (params) =>
      let
        // Split strings into list by each character, convert to upper, remove hash
        Source = if params{0} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{0}), "#")) else "#000000",
        
        // Split the Source by each character
        SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

        GetHue = (hexlist) =>
          let 
            // Build the RGB list
            RGB = List.Combine({{"0".."9"},{"A".."F"}}),
            
            // Sub function to figure out RGB value
            GetRGB = (cval1, cval2) =>
              let 
                RGBVal = (Number.From(cval1) * 16) + Number.From(cval2)
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
        Result
  ), 
  fnType = type function (HEX as text) as number
    meta [
      Documentation.Name = "GetColorHue", 
      Documentation.LongDescription = "This function calculates the hue of a color given its HEX code.", 
      Documentation.Examples = {
        [
          Description = "Calculate the hue of a color given its HEX code.",
          Code        = "=GetColorHue(""#FF5733"")", 
          Result      = "10.588235294117647"
        ]
      }
    ]
in
  Value.ReplaceType(GetColorHue, fnType)

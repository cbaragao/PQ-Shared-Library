let
  // Define the function using simplified syntax
  GetFontColor = (HEX as text, optional culture as nullable text) as text =>
      let
        // Use default culture if not provided
        cultureToUse = culture ?? "en-US",
        
        // Split strings into list by each character, convert to upper, remove hash
        Source = if HEX <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX, cultureToUse), "#", 0, Comparer.Ordinal)) else "#000000",
        
        // Set gamma for sRGB to linear RGB conversion
        gamma = 2.2,

        // Get sRGB subfunction - converts hex digit pair to sRGB value (0-1 range)
        GetSRGB = (cval1 as number, cval2 as number) as number =>
          let 
            SRGB = ((cval1 * 16) + cval2) / 255
          in       
            SRGB,

        // Build the RGB list
        RGB = List.Combine({{"0".."9"},{"A".."F"}}),

        // Split the Source by each character
        SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

        // Each value is essentially the index position of the RGB list
        r1 = List.PositionOf(RGB, SplitHex{0}, Occurrence.First, Comparer.Ordinal),
        r2 = List.PositionOf(RGB, SplitHex{1}, Occurrence.First, Comparer.Ordinal),
        g1 = List.PositionOf(RGB, SplitHex{2}, Occurrence.First, Comparer.Ordinal),
        g2 = List.PositionOf(RGB, SplitHex{3}, Occurrence.First, Comparer.Ordinal),
        b1 = List.PositionOf(RGB, SplitHex{4}, Occurrence.First, Comparer.Ordinal),
        b2 = List.PositionOf(RGB, SplitHex{5}, Occurrence.First, Comparer.Ordinal),

        // Calculate rnum, gnum, bnum
        rnum = GetSRGB(r1, r2),
        gnum = GetSRGB(g1, g2),
        bnum = GetSRGB(b1, b2),

        // Calculate perceived luminance using sRGB relative luminance coefficients
        // ITU-R BT.709 standard weights: red=21.26%, green=71.52%, blue=7.22%
        luminance = (0.2126 * Number.Power(rnum, gamma)) + 
                    (0.7152 * Number.Power(gnum, gamma)) + 
                    (0.0722 * Number.Power(bnum, gamma)),

        // Determine font color based on luminance threshold
        // >0.5 luminance = dark background -> white text
        // <=0.5 luminance = light background -> black text
        fontcolor = if luminance > 0.5 then "#FFFFFF" else "#000000"
      in 
        fontcolor,

  // Define the function type with metadata
  fnType = type function (HEX as text, optional culture as nullable text) as text
    meta [
      Documentation.Name = "Get-FontColor",
      Documentation.LongDescription = "Determines whether black (#000000) or white (#FFFFFF) text should be used on a colored background for optimal readability. The function calculates the perceived luminance using the ITU-R BT.709 standard coefficients (red=21.26%, green=71.52%, blue=7.22%) with gamma correction (2.2). If luminance > 0.5, the background is considered dark and white text is recommended; otherwise, black text is recommended.",
      Documentation.Examples = {
        [
          Description = "Get the optimal font color for a medium-dark background (#666A86).",
          Code        = "GetFontColor(""#666A86"")",
          Result      = "#000000"
        ],
        [
          Description = "Get the optimal font color for a light background.",
          Code        = "GetFontColor(""#E8DDB5"")",
          Result      = "#000000"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetFontColor, fnType)

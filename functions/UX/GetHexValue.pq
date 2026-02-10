let
  // Define the function using simplified syntax
  GetHexValue = (red as number, green as number, blue as number, optional culture as nullable text) as text =>
      let
        // Use default culture if not provided (for potential future text operations)
        cultureToUse = culture ?? "en-US",
        
        // Build the RGB list (hex digits 0-9, A-F)
        RGB = List.Combine({{"0" .. "9"}, {"A" .. "F"}}), 
        
        // Function to convert RGB values to hex
        ConvertToHex = (r as number, g as number, b as number) as text =>
          let
            // Convert each RGB component to two hex digits
            r1        = RGB{Number.IntegerDivide(r, 16)}, 
            r2        = RGB{Number.Mod(r, 16)}, 
            g1        = RGB{Number.IntegerDivide(g, 16)}, 
            g2        = RGB{Number.Mod(g, 16)}, 
            b1        = RGB{Number.IntegerDivide(b, 16)}, 
            b2        = RGB{Number.Mod(b, 16)}, 
            HexOutput = "#" & r1 & r2 & g1 & g2 & b1 & b2
          in
            HexOutput
      in 
        ConvertToHex(red, green, blue),

  // Define the function type with metadata
  fnType = type function (red as number, green as number, blue as number, optional culture as nullable text) as text
    meta [
      Documentation.Name = "Get-HexValue",
      Documentation.LongDescription = "Converts RGB color values (0-255 range) to hexadecimal color code format (#RRGGBB). Each RGB component is converted to two hexadecimal digits using integer division and modulo operations. This is the inverse operation of GetRGBValue.",
      Documentation.Examples = {
        [
          Description = "Convert pure white RGB values to hex.",
          Code        = "GetHexValue(255, 255, 255)",
          Result      = "#FFFFFF"
        ],
        [
          Description = "Convert pure red RGB values to hex.",
          Code        = "GetHexValue(255, 0, 0)",
          Result      = "#FF0000"
        ],
        [
          Description = "Convert dutch white RGB values to hex.",
          Code        = "GetHexValue(232, 221, 181)",
          Result      = "#E8DDB5"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetHexValue, fnType)

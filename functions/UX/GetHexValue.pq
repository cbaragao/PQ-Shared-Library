let
  // Define the function using Function.From
  GetHexValue = Function.From(
    type function (red as number, green as number, blue as number) as text,
    (params) =>
      let
        // Build the RGB list
        RGB = List.Combine({{"0" .. "9"}, {"A" .. "F"}}), 
        
        // Function to convert RGB values to hex
        ConvertToHex = (r, g, b) =>
          let
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
        ConvertToHex(params{0}, params{1}, params{2})
  ),

  // Define the function type with metadata
  fnType = type function (red as number, green as number, blue as number) as text
    meta [
      Documentation.Name = "GetHexValue",
      Documentation.LongDescription = "This function converts RGB values to hex codes.",
      Documentation.Examples = {
        [
          Description = "This converts 255, 255, 255 to hex.",
          Code        = "=GetHexValue(255, 255, 255)",
          Result      = "#FFFFFF"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetHexValue, fnType)

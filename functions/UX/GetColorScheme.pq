//from the color api: https://www.thecolorapi.com/docs
let
  GetColorScheme = (hex as text, mode as number, count as number, optional culture as nullable text) as table =>
      let
        // Use default culture if not provided
        cultureToUse = culture ?? "en-US",
        
        num = Text.From(count, cultureToUse), 
        hx = if Text.StartsWith(hex, "#") then Text.Replace(hex, "#", "") else hex, 
        md = 
          if mode = 0 then
            "monochrome"
          else if mode = 1 then
            "monochrome-dark"
          else if mode = 2 then
            "monochrome-light"
          else if mode = 3 then
            "analogic"
          else if mode = 4 then
            "complement"
          else if mode = 5 then
            "analogic-complement"
          else if mode = 6 then
            "triad"
          else if mode = 7 then
            "quad"
          else 
            "monochrome", 
        call = Json.Document(
          Web.Contents(
            "https://www.thecolorapi.com/scheme?hex="
              & hx
              & "&format=json&mode="
              & md
              & "&count="
              & num
          )
        )[colors], 
        to_table = Table.FromList(call, Splitter.SplitByNothing(), null, null, ExtraValues.Error), 
        expanded = Table.ExpandRecordColumn(
          to_table, 
          "Column1", 
          {"hex", "rgb", "name", "contrast"}, 
          {"hex", "rgb", "name", "contrast"}
        ), 
        expanded_hex = Table.ExpandRecordColumn(expanded, "hex", {"value"}, {"hex"}), 
        expanded_rgb = Table.ExpandRecordColumn(expanded_hex, "rgb", {"value"}, {"rgb"}), 
        expanded_contrast = Table.ExpandRecordColumn(
          expanded_rgb, 
          "contrast", 
          {"value"}, 
          {"contrast"}
        ), 
        expanded_name = Table.ExpandRecordColumn(
          expanded_contrast, 
          "name", 
          {"value", "closest_named_hex"}, 
          {"closest_name", "closest_named_hex"}
        ), 
        result = Table.TransformColumnTypes(
          expanded_name, 
          {
            {"hex", type text}, 
            {"rgb", type text}, 
            {"closest_name", type text}, 
            {"closest_named_hex", type text}, 
            {"contrast", type text}
          }
        )
      in
        result,
        
  // Define the function type with metadata
  fnType = type function (hex as text, mode as number, count as number, optional culture as nullable text) as table
    meta [
      Documentation.Name            = "Get-ColorScheme", 
      Documentation.LongDescription = "Retrieves a color scheme from The Color API (thecolorapi.com) based on a hex color code. Returns a table with hex values, RGB values, color names, and contrast values. Mode parameter determines the scheme type: 0=monochrome, 1=monochrome-dark, 2=monochrome-light, 3=analogic, 4=complement, 5=analogic-complement, 6=triad, 7=quad. Count parameter specifies the number of colors to return (typically 1-10).",
      Documentation.Examples = {
        [
          Description = "Get a monochrome color scheme with 5 colors based on red.",
          Code        = "GetColorScheme(""#FF0000"", 0, 5)", 
          Result      = "Table with 5 rows containing hex, rgb, closest_name, closest_named_hex, and contrast columns"
        ],
        [
          Description = "Get a complementary color scheme with 2 colors based on blue.",
          Code        = "GetColorScheme(""#0000FF"", 4, 2)", 
          Result      = "Table with 2 rows showing complementary colors"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetColorScheme, fnType)
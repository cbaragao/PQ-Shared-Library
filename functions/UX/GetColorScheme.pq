//from the color api: https://www.thecolorapi.com/docs
let
  GetColorScheme = Function.From(
    type function (hex as text, mode as number, count as number) as table, 
    (params) =>
      let
        num = Text.From(params{2}), 
        hx = if Text.StartsWith(params{0}, "#") then Text.Replace(params{0}, "#", "") else params{0}, 
        md = 
          if params{1} = 0 then
            "monochrome"
          else if params{1} = 1 then
            "monochrome-dark"
          else if params{1} = 2 then
            "monochrome-light"
          else if params{1} = 3 then
            "analogic"
          else if params{1} = 4 then
            "complement"
          else if params{1} = 5 then
            "analogic-complement"
          else if params{1} = 6 then
            "triad"
          else
            "quad", 
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
        result
  ), 
  // Define the function type with metadata
  fnType = type function (hex as text, mode as number, count as number) as table
    meta [
      Documentation.Name            = "GetColorScheme", 
      Documentation.LongDescription = "Get Color Scheme from the Color API."
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetColorScheme, fnType)
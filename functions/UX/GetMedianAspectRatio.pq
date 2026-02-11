let 
    // Compute median slope and aspect ratio between two series
    GetMedianAspectRatio = (x as list, y as list, optional culture as nullable text) as record =>
      let
        cultureToUse = culture ?? "en-US",
        range_x = List.Max(x) - List.Min(x),
        range_y = List.Max(y) - List.Min(y),
        max = List.Count(x) - 1,
        div = if range_x = 0 and range_y = 0 then { Number.NaN }
              else if range_x = 0 then { Number.PositiveInfinity }
              else if range_y = 0 then { 0 }
              else
                let
                  acc = List.Generate(
                    () => [i = 0, dx = 0, dy = 0],
                    each [i] < max,
                    each [i = [i] + 1, dx = (x{[i] + 1} - x{[i]}), dy = (y{[i] + 1} - y{[i]})]
                  ),
                  slopes = List.Transform(
                    List.Skip(acc, 1),
                    each if Record.Field(_, "dx") = 0 then Number.PositiveInfinity else Number.Abs(Record.Field(_, "dy") / Record.Field(_, "dx")) as number
                  )
                in
                  slopes,
        median = List.Median(div),
        a = if median = 0 then Number.PositiveInfinity else if median = Number.PositiveInfinity then 0 else 1 / median
      in
        [aspect_ratio = a, median_slope = median],

    fnType = type function (x as list, y as list, optional culture as nullable text) as record meta 
    [Documentation.Name = "Get-MedianAspectRatio",
    Documentation.LongDescription = "Compute the median slope and the corresponding aspect ratio (1/median_slope) between two numeric series.",
    Documentation.Examples = {
      [Description = "Example: equal increments produce slope 1 and aspect_ratio 1",
       Code        = "GetMedianAspectRatio({1, 2, 3, 4}, {4, 5, 6, 7})",
       Result      = "record with aspect_ratio = 1 and median_slope = 1"]
    }]
    in  
Value.ReplaceType(GetMedianAspectRatio, fnType)

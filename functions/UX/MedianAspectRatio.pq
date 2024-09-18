let
  MedianAspectRatio = Function.From(
    type function (x as list, y as list) as record, 
    (params) =>
      let
        // Get the range of the x series/column by subtracting max from min
        range_x = List.Max(params{0}) - List.Min(params{0}), 
        
        // Get the range of the y series/column by subtracting max from min
        range_y = List.Max(params{1}) - List.Min(params{1}), 
        
        // Get max index of one of the columns for List.Generate
        max = List.Count(params{0}) - 1, 
        
        // The equation asks for running differences (think lag in SQL) divided by the range for x and y
        acc = List.Generate(
          () => [i = 0, dx = 0, dy = 0], 
          each [i] < max, 
          each [i = [i] + 1, dx = (params{0}{[i] + 1} - params{0}{[i]}) / range_x, dy = (params{1}{[i] + 1} - params{1}{[i]}) / range_y]
        ), 
        
        // Then divide each dx and dy. After that, take the absolute value
        div = List.Transform(
          List.Skip(acc, 1), 
          each Number.Abs(Record.Field(_, "dy") / Record.Field(_, "dx"))
        ), 
        
        // Get the median of those values
        median = List.Median(div), 
        
        // Get aspect ratio
        a = (1 / median)
      in
        // Return a record with aspect ratio and median absolute slope
        [aspect_ratio = a, median_slope = median]
  ), 
  fnType = type function (x as list, y as list) as record
    meta [
      Documentation.Name = "MedianAspectRatio", 
      Documentation.LongDescription = "This function calculates the median aspect ratio for charts based on two lists of numbers.", 
      Documentation.Examples = {
        [
          Description = "Calculate the median aspect ratio for two lists of numbers.",
          Code        = "=MedianAspectRatio({1, 2, 3, 4}, {4, 5, 6, 7})", 
          Result      = "[aspect_ratio = 1, median_slope = 1]"
        ]
      }
    ]
in
  Value.ReplaceType(MedianAspectRatio, fnType)

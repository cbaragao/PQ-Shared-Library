let
  MedianAspectRatio = (x as list, y as list, optional culture as nullable text) as record =>
      let
        // Use default culture if not provided (for potential future text operations)
        cultureToUse = culture ?? "en-US",
        
        // Get the range of the x series/column by subtracting max from min
        range_x = List.Max(x) - List.Min(x), 
        
        // Get the range of the y series/column by subtracting max from min
        range_y = List.Max(y) - List.Min(y), 
        
        // Get max index of one of the columns for List.Generate
        max = List.Count(x) - 1, 
        
        // The equation asks for running differences (think lag in SQL) divided by the range for x and y
        // This calculates normalized slopes between consecutive points
        acc = List.Generate(
          () => [i = 0, dx = 0, dy = 0], 
          each [i] < max, 
          each [i = [i] + 1, dx = (x{[i] + 1} - x{[i]}) / range_x, dy = (y{[i] + 1} - y{[i]}) / range_y]
        ), 
        
        // Then divide each dy by dx to get slope, and take the absolute value
        // This gives us the absolute slopes of all segments
        div = List.Transform(
          List.Skip(acc, 1), 
          each Number.Abs(Record.Field(_, "dy") / Record.Field(_, "dx")) as number
        ), 
        
        // Get the median of those absolute slopes
        // Based on William Cleveland's "banking to 45 degrees" principle for optimal chart readability
        median = List.Median(div), 
        
        // Get aspect ratio (inverse of median slope)
        // A median slope of 1 (45 degrees) gives aspect ratio of 1
        a = (1 / median)
      in
        // Return a record with aspect ratio and median absolute slope
        [aspect_ratio = a, median_slope = median], 
  fnType = type function (x as list, y as list, optional culture as nullable text) as record
    meta [
      Documentation.Name = "Median-AspectRatio", 
      Documentation.LongDescription = "Calculates the optimal aspect ratio for chart visualization based on the median absolute slope of data points. This implements William Cleveland's 'banking to 45 degrees' principle, which suggests that chart aspect ratios should be chosen so that the median absolute slope of line segments is 1 (45 degrees), maximizing the visual discrimination of slope differences. The function takes two lists (x and y coordinates) and returns a record with the recommended aspect_ratio and the calculated median_slope.", 
      Documentation.Examples = {
        [
          Description = "Calculate the median aspect ratio for two lists with equal increments.",
          Code        = "MedianAspectRatio({1, 2, 3, 4}, {4, 5, 6, 7})", 
          Result      = "[aspect_ratio = 1, median_slope = 1]"
        ],
        [
          Description = "Calculate aspect ratio for data with steeper slope.",
          Code        = "MedianAspectRatio({1, 2, 3}, {1, 4, 9})", 
          Result      = "[aspect_ratio > 1, median_slope < 1] (wider chart recommended)"
        ]
      }
    ]
in
  Value.ReplaceType(MedianAspectRatio, fnType)

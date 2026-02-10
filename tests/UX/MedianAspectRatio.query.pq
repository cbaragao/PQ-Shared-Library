let
    // Define the function directly in the test file
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
    
    // Test 1: Original example - equal increments (slope = 1, aspect_ratio = 1)
    test1 = MedianAspectRatio({1, 2, 3, 4}, {4, 5, 6, 7}),
    result1 = if test1[aspect_ratio] = 1 and test1[median_slope] = 1 
              then "Test 1 Passed" 
              else "Test 1 Failed: Got aspect_ratio=" & Number.ToText(test1[aspect_ratio]) & ", median_slope=" & Number.ToText(test1[median_slope]),
    
    // Test 2: Simple linear data with slope = 2 (steeper)
    test2 = MedianAspectRatio({1, 2, 3}, {0, 2, 4}),
    expectedSlope2 = 2, // dy/dx = 2/1 = 2
    expectedAspectRatio2 = 0.5, // 1/2 = 0.5 (taller chart)
    result2 = if test2[median_slope] = expectedSlope2 and test2[aspect_ratio] = expectedAspectRatio2
              then "Test 2 Passed" 
              else "Test 2 Failed: Got aspect_ratio=" & Number.ToText(test2[aspect_ratio]),
    
    // Test 3: Horizontal line (all y values same) - undefined slope
    test3 = MedianAspectRatio({1, 2, 3, 4}, {5, 5, 5, 5}),
    result3 = if test3[median_slope] = 0 and test3[aspect_ratio] = Number.PositiveInfinity
              then "Test 3 Passed" 
              else "Test 3 Failed: Got median_slope=" & Number.ToText(test3[median_slope]),
    
    // Test 4: Vertical trend (steep slope)
    test4 = MedianAspectRatio({1, 2, 3}, {1, 10, 19}),
    // dy = 9, dx = 1, normalized: dy/(19-1)=0.5, dx/(3-1)=0.5, slope=1
    result4 = if test4[median_slope] = 1 and test4[aspect_ratio] = 1
              then "Test 4 Passed" 
              else "Test 4 Failed",
    
    // Test 5: With custom culture parameter
    test5 = MedianAspectRatio({1, 2, 3, 4}, {4, 5, 6, 7}, "en-US"),
    result5 = if test5[aspect_ratio] = 1 and test5[median_slope] = 1 
              then "Test 5 Passed" 
              else "Test 5 Failed",
    
    // Test 6: Verify result is a record type
    test6Type = Value.Type(test1),
    result6 = if Type.Is(test6Type, type record) then "Test 6 Passed" else "Test 6 Failed: Not a record type",
    
    // Test 7: Verify aspect_ratio field exists
    hasAspectRatio = Record.HasFields(test1, "aspect_ratio"),
    result7 = if hasAspectRatio then "Test 7 Passed" else "Test 7 Failed: Missing aspect_ratio field",
    
    // Test 8: Verify median_slope field exists
    hasMedianSlope = Record.HasFields(test1, "median_slope"),
    result8 = if hasMedianSlope then "Test 8 Passed" else "Test 8 Failed: Missing median_slope field",
    
    // Test 9: Structural test - verify parameter count
    metadata = Value.Metadata(Value.Type(MedianAspectRatio)),
    params = Type.FunctionParameters(Value.Type(MedianAspectRatio)),
    paramCount = Record.FieldCount(params),
    result9 = if paramCount = 3 then "Test 9 Passed" else "Test 9 Failed: Expected 3 parameters, got " & Number.ToText(paramCount),
    
    // Test 10: Verify parameter names
    paramNames = Record.FieldNames(params),
    hasX = List.Contains(paramNames, "x"),
    hasY = List.Contains(paramNames, "y"),
    hasCulture = List.Contains(paramNames, "culture"),
    result10 = if hasX and hasY and hasCulture then "Test 10 Passed" else "Test 10 Failed: Missing expected parameters",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Equal increments (slope=1)", result1},
            {"Test 2: Steeper slope (slope=2)", result2},
            {"Test 3: Horizontal line (slope=0)", result3},
            {"Test 4: Vertical trend", result4},
            {"Test 5: Custom culture parameter", result5},
            {"Test 6: Result is record type", result6},
            {"Test 7: Has aspect_ratio field", result7},
            {"Test 8: Has median_slope field", result8},
            {"Test 9: Parameter count", result9},
            {"Test 10: Parameter names", result10}
        }
    )
in
    summary

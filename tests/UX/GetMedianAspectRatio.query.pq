let
    // Define the function directly in the test file (renamed to GetMedianAspectRatio)
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

    // Test 1: Original example - equal increments (slope = 1, aspect_ratio = 1)
    test1 = GetMedianAspectRatio({1, 2, 3, 4}, {4, 5, 6, 7}),
    result1 = if test1[aspect_ratio] = 1 and test1[median_slope] = 1 then "Test 1 Passed" else "Test 1 Failed: Got aspect_ratio=" & Number.ToText(test1[aspect_ratio]) & ", median_slope=" & Number.ToText(test1[median_slope]),

    // Test 2: Simple linear data with slope = 2 (steeper)
    test2 = GetMedianAspectRatio({1, 2, 3}, {0, 2, 4}),
    expectedSlope2 = 2,
    expectedAspectRatio2 = 0.5,
    result2 = if test2[median_slope] = expectedSlope2 and test2[aspect_ratio] = expectedAspectRatio2 then "Test 2 Passed" else "Test 2 Failed: Got aspect_ratio=" & Number.ToText(test2[aspect_ratio]) & ", median_slope=" & Number.ToText(test2[median_slope]),

    // Other tests (kept same logic)
    test3 = GetMedianAspectRatio({1, 2, 3, 4}, {5, 5, 5, 5}),
    result3 = if (test3[median_slope] = 0 or Number.IsNaN(test3[median_slope])) and test3[aspect_ratio] = Number.PositiveInfinity then "Test 3 Passed" else "Test 3 Failed: Got median_slope=" & Number.ToText(test3[median_slope]) & ", aspect_ratio=" & Number.ToText(test3[aspect_ratio]),

    test4 = GetMedianAspectRatio({1, 2, 3}, {1, 10, 19}),
    expectedSlope4 = 9,
    expectedAspectRatio4 = 1/9,
    result4 = if test4[median_slope] = expectedSlope4 and test4[aspect_ratio] = expectedAspectRatio4 then "Test 4 Passed" else "Test 4 Failed: Got aspect_ratio=" & Number.ToText(test4[aspect_ratio]) & ", median_slope=" & Number.ToText(test4[median_slope]),

    test5 = GetMedianAspectRatio({1, 2, 3, 4}, {4, 5, 6, 7}, "en-US"),
    result5 = if test5[aspect_ratio] = 1 and test5[median_slope] = 1 then "Test 5 Passed" else "Test 5 Failed",

    test6Type = Value.Type(test1),
    result6 = if Type.Is(test6Type, type record) then "Test 6 Passed" else "Test 6 Failed: Not a record type",

    hasAspectRatio = Record.HasFields(test1, "aspect_ratio"),
    result7 = if hasAspectRatio then "Test 7 Passed" else "Test 7 Failed: Missing aspect_ratio field",

    hasMedianSlope = Record.HasFields(test1, "median_slope"),
    result8 = if hasMedianSlope then "Test 8 Passed" else "Test 8 Failed: Missing median_slope field",

    metadata = Value.Metadata(Value.Type(GetMedianAspectRatio)),
    params = Type.FunctionParameters(Value.Type(GetMedianAspectRatio)),
    paramCount = Record.FieldCount(params),
    result9 = if paramCount = 3 then "Test 9 Passed" else "Test 9 Failed: Expected 3 parameters, got " & Number.ToText(paramCount),

    paramNames = Record.FieldNames(params),
    hasX = List.Contains(paramNames, "x"),
    hasY = List.Contains(paramNames, "y"),
    hasCulture = List.Contains(paramNames, "culture"),
    result10 = if hasX and hasY and hasCulture then "Test 10 Passed" else "Test 10 Failed: Missing expected parameters",

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

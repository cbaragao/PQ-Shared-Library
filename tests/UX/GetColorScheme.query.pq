let
    // Define the function directly in the test file (from the color api: https://www.thecolorapi.com/docs)
    GetColorScheme = (hex as text, mode as number, count as number, optional culture as nullable text) as table =>
        let
          // Use default culture if not provided
          cultureToUse = culture ?? "en-US",
          
          num = Text.From(count, cultureToUse), 
          hx = if Text.StartsWith(hex, "#", Comparer.Ordinal) then Text.Replace(hex, "#", "", Comparer.Ordinal) else hex, 
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
    
    // Test 1: Validate function is callable (type check)
    test1 = Value.Type(GetColorScheme),
    result1 = if Type.Is(test1, type function) then "Test 1 Passed" else "Test 1 Failed",
    
    // Test 2: Validate function has 4 parameters
    functionType = Value.Type(GetColorScheme),
    functionRecord = Type.FunctionParameters(functionType),
    paramCount = Record.FieldCount(functionRecord),
    result2 = if paramCount = 4 then "Test 2 Passed" else "Test 2 Failed: Expected 4 parameters, got " & Text.From(paramCount, "en-US"),
    
    // Test 3: Validate parameter names
    paramNames = Record.FieldNames(functionRecord),
    expectedNames = {"hex", "mode", "count", "culture"},
    result3 = if paramNames = expectedNames then "Test 3 Passed" else "Test 3 Failed",
    
    // Test 4: Validate return type is table
    returnType = Type.FunctionReturn(functionType),
    result4 = if Type.Is(returnType, type table) then "Test 4 Passed" else "Test 4 Failed",
    
    // Note: We cannot easily test the API call without internet connectivity
    // Real API testing should be done manually with valid endpoints
    // The function calls an external Color API which requires network access
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Function is callable", result1},
            {"Test 2: Function has 4 parameters", result2},
            {"Test 3: Parameter names are correct", result3},
            {"Test 4: Return type is table", result4}
        }
    )
in
    summary

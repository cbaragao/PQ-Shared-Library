let
    // Define the function directly in the test file
    TestWebAimContrast = (background_hex as text, font_hex as text, optional culture as nullable text) as text =>
      let
        // Use default culture if not provided
        cultureToUse = culture ?? "en-US",
        
        // Nested function to remove leading hash for API call and to check length and prevent errors
        remove_hash = (hex as text) as text =>
          let
            // Trim any spaces
            trim = Text.Trim(hex), 
            // Remove leading hash
            remove = if Text.StartsWith(trim, "#") then Text.RemoveRange(trim, 0, 1) else trim, 
            // Check length, set to white if not equal to 6
            check_length = if Text.Length(remove, cultureToUse) <> 6 then "#FFFFFF" else remove
          in
            check_length, 

        // Pass background color
        bg = remove_hash(background_hex), 
        // Pass font color 
        font = remove_hash(font_hex), 

        // Call the API
        Call = Json.Document(
          Web.Contents(
            "https://webaim.org/resources/contrastchecker/?fcolor=" & font & "&bcolor=" & bg & "&api"
          )
        ), 

        // If any fail, transform the record field to be more descriptive, else null 
        Transform = Record.TransformFields(
          Call, 
          {
            {"AA", each if _ = "fail" then "WCAG 2.0 Level AA Normal Font Test Failed" else null}, 
            {"AALarge", each if _ = "fail" then "WCAG 2.0 Level AA Large Font Test Failed" else null}, 
            {"AAA", each if _ = "fail" then "WCAG 2.0 Level AAA Normal Font Test Failed" else null}, 
            {"AAALarge", each if _ = "fail" then "WCAG 2.0 Level AAA Large Font Test Failed" else null}
          }
        ), 

        // Filter out tests that passed 
        Select = List.Select(Record.ToList(Transform), each _ <> null), 

        // Concatenate the ratio and any failures
        Concat = List.Accumulate(
          Select, 
          "", 
          (state as text, current as any) as text =>
            if List.PositionOf(Select, current) = 0 then
              Text.Combine({"Ratio: ", Text.From(current, cultureToUse), " to 1#(lf)"})
            else if List.PositionOf(Select, current) = 1 then
              Text.Combine({state, "Test Failures:#(lf)", current, "#(lf)"})
            else
              Text.Combine({state, current, "#(lf)"})
        ), 

        // If all pass then let the user know
        If_All_Pass = 
          if Text.Contains(Concat, "Test Failures") = false then
            Text.Combine({Concat, "Test Failures: None"})
          else
            Concat
      in
        If_All_Pass,
    
    // Test 1: Validate function is callable (type check)
    test1 = Value.Type(TestWebAimContrast),
    result1 = if Type.Is(test1, type function) then "Test 1 Passed" else "Test 1 Failed",
    
    // Test 2: Validate function has 3 parameters
    functionType = Value.Type(TestWebAimContrast),
    functionRecord = Type.FunctionParameters(functionType),
    paramCount = Record.FieldCount(functionRecord),
    result2 = if paramCount = 3 then "Test 2 Passed" else "Test 2 Failed",
    
    // Test 3: Validate parameter names
    paramNames = Record.FieldNames(functionRecord),
    expectedNames = {"background_hex", "font_hex", "culture"},
    result3 = if paramNames = expectedNames then "Test 3 Passed" else "Test 3 Failed",
    
    // Note: We cannot easily test the API  call without internet connectivity
    // Real API testing should be done manually with valid endpoints
    // The function calls an external WebAIM API which requires network access
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Function is callable", result1},
            {"Test 2: Function has 3 parameters", result2},
            {"Test 3: Parameter names are correct", result3}
        }
    )
in
    summary

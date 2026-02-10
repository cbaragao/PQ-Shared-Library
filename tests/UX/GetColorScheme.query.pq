let
    // Load the function from file
    GetColorScheme = Expression.Evaluate(Text.FromBinary(File.Contents("functions/UX/GetColorScheme.pq")), #shared),
    
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

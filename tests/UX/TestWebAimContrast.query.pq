let
    // Load the function from file
    TestWebAimContrast = Expression.Evaluate(Text.FromBinary(File.Contents("functions/UX/TestWebAimContrast.pq")), #shared),
    
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

let
    // Load the function from file
    InvokePostRequest = Expression.Evaluate(Text.FromBinary(File.Contents("functions/Utils/InvokePostRequest.pq")), #shared),
    
    // Test 1: Validate function is callable (type check)
    test1 = Value.Type(InvokePostRequest),
    result1 = if Type.Is(test1, type function) then "Test 1 Passed" else "Test 1 Failed",
    
    // Test 2: Validate function has 3 parameters (SvcUrl, Content, optional ContentType)
    functionType = Value.Type(InvokePostRequest),
    functionRecord = Type.FunctionParameters(functionType),
    paramCount = Record.FieldCount(functionRecord),
    result2 = if paramCount = 3 then "Test 2 Passed" else "Test 2 Failed: Expected 3 parameters, got " & Text.From(paramCount, "en-US"),
    
    // Test 3: Validate parameter names
    paramNames = Record.FieldNames(functionRecord),
    expectedNames = {"SvcUrl", "Content", "ContentType"},
    result3 = if paramNames = expectedNames then "Test 3 Passed" else "Test 3 Failed",
    
    // Test 4: Validate return type is 'any'
    returnType = Type.FunctionReturn(functionType),
    result4 = if Type.Is(returnType, type any) then "Test 4 Passed" else "Test 4 Failed",
    
    // Note: We cannot easily test actual HTTP POST without external dependencies
    // Real API testing should be done manually with valid endpoints
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Function is callable", result1},
            {"Test 2: Function has 3 parameters", result2},
            {"Test 3: Parameter names are correct", result3},
            {"Test 4: Return type is 'any'", result4}
        }
    )
in
    summary

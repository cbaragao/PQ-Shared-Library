let
    // Include the function being tested
    InvokeSQLQuery = (Source as any, Query as text) as table =>
        let
            // Run the SQL query with native query options
            Run = Value.NativeQuery(
                Source, 
                Query, 
                null,   
                // Enable query folding and preserve data types
                [EnableFolding = true, PreserveTypes = true]
            )
        in
            Run,

    // Test Case 1: Verify function signature and parameter types
    Test1_Description = "Function accepts Source (any) and Query (text) parameters",
    Test1_Result = try 
        let
            FunctionType = Type.FunctionParameters(Value.Type(InvokeSQLQuery)),
            HasSourceParam = Record.HasFields(FunctionType, "Source"),
            HasQueryParam = Record.HasFields(FunctionType, "Query"),
            SourceType = FunctionType[Source],
            QueryType = FunctionType[Query]
        in
            HasSourceParam and HasQueryParam and Type.Is(QueryType, type text)
    otherwise false,
    Test1_Expected = "Function should have Source and Query parameters with correct types",
    Test1_Pass = Test1_Result,

    // Test Case 2: Verify function return type is table
    Test2_Description = "Function return type is table",
    Test2_Result = try 
        let
            FunctionType = Value.Type(InvokeSQLQuery),
            ReturnType = Type.FunctionReturn(FunctionType)
        in
            Type.Is(ReturnType, type table)
    otherwise false,
    Test2_Expected = "Function should return type table",
    Test2_Pass = Test2_Result,

    // Test Case 3: Verify function handles invalid connection gracefully
    Test3_Description = "Function throws appropriate error for invalid connection",
    Test3_Result = try 
        let
            InvalidSource = null,
            Result = InvokeSQLQuery(InvalidSource, "SELECT 1")
        in
            false  // Should not reach here
    otherwise true,  // Expected to error
    Test3_Expected = "Function should error when Source is null/invalid",
    Test3_Pass = Test3_Result,

    // Test Case 4: Verify function metadata (Documentation.Name)
    Test4_Description = "Function has correct documentation metadata",
    Test4_Result = try 
        let
            FunctionType = Value.Type(InvokeSQLQuery),
            Metadata = Value.Metadata(FunctionType),
            HasDocName = Record.HasFields(Metadata, "Documentation.Name"),
            DocName = if HasDocName then Metadata[Documentation.Name] else null
        in
            DocName = "InvokeSQLQuery"
    otherwise false,
    Test4_Expected = "Documentation.Name should be 'InvokeSQLQuery'",
    Test4_Pass = Test4_Result,

    // Note about actual database testing
    TestNote = "Note: Full integration testing requires an actual database connection. " &
               "These tests validate function structure and type safety. " &
               "To test with real data, connect to a SQL Server/database and execute: " &
               "InvokeSQLQuery(Sql.Database(""server"", ""database""), ""SELECT TOP 10 * FROM TableName"")",

    // Create results table
    Source = #table(
        {"TestCase", "Description", "Expected", "Pass", "Notes"},
        {
            {
                "Test 1",
                Test1_Description,
                Test1_Expected,
                Test1_Pass,
                "Validates function parameter signature"
            },
            {
                "Test 2",
                Test2_Description,
                Test2_Expected,
                Test2_Pass,
                "Validates function return type"
            },
            {
                "Test 3",
                Test3_Description,
                Test3_Expected,
                Test3_Pass,
                "Validates error handling for invalid source"
            },
            {
                "Test 4",
                Test4_Description,
                Test4_Expected,
                Test4_Pass,
                "Validates documentation metadata"
            },
            {
                "Info",
                "Full Database Testing",
                TestNote,
                null,
                "See TestNote for integration testing instructions"
            }
        }
    )
in
    Source

let
    // Include function being tested
    GetFileText = (filepath as text) as text =>
        let
            // Read the file contents as a table with one column
            file = Table.FromColumns({Lines.FromBinary(File.Contents(filepath), null, null, 1252)}),
            
            // Combine all lines into a single text string, separated by line feeds
            result = Text.Combine(file[Column1], "#(lf)")
        in
            result,
    
    // Test cases - Note: This function requires actual file access
    // Testing with function metadata and structure validation
    Source = #table(
        {"TestCase", "Description", "Pass"},
        {
            {
                "Function exists",
                "Verify GetFileText function is defined",
                GetFileText <> null
            },
            {
                "Function signature",
                "Verify function accepts text parameter",
                Type.FunctionParameters(Value.Type(GetFileText)) = [filepath = type text]
            },
            {
                "Return type",
                "Verify function returns text type",
                Type.FunctionReturn(Value.Type(GetFileText)) = type text
            }
        }
    ),
    
    // Add note about file-based testing
    TestNote = "NOTE: This function reads actual files from disk. To test with real data, " &
               "create a test file and add test cases with actual file paths. " &
               "Example: GetFileText(""C:\\test\\sample.txt"")"
in
    Source

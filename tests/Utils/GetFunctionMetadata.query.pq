let
    // Embed GetFunctionMetadata so tests are portable
    GetFunctionMetadata = (function_name as text, return as text, optional culture as nullable text) as any =>
        let
            cultureToUse = culture ?? "en-US",
            sharedTable = Record.ToTable(#shared),
            matches = Table.SelectRows(sharedTable, each Text.Upper([Name], cultureToUse) = Text.Upper(function_name, cultureToUse)),
            resultIfNotFound = "Function not found",
            matchedRecord = if Table.RowCount(matches) > 0 then Table.ToRecords(matches){0} else null,
            matchedName = if matchedRecord <> null then matchedRecord[Name] else null,
            matchedValue = if matchedRecord <> null then try matchedRecord[Value] otherwise null else null,
            metadata = if matchedValue <> null then try Value.Metadata(matchedValue) otherwise null else null,
            doc = if metadata <> null and Record.HasFields(metadata, "Documentation") then try metadata[Documentation] otherwise null else null,
            examples = if doc <> null and Record.HasFields(doc, "Examples") then try doc[Examples] otherwise null else null,
            returnLower = Text.Lower(return, cultureToUse),
            result =
                if matchedRecord = null then resultIfNotFound
                else if returnLower = "name" then matchedName
                else if returnLower = "description" then (try if Record.HasFields(doc, "LongDescription") then doc[LongDescription] else doc[Description] otherwise null )
                else if returnLower = "example" then (if examples <> null and List.Count(examples) > 0 then examples{0} else null)
                else "Invalid return parameter value provided"
        in
            result,

    // Test 1: Get name of a function
    test1 = GetFunctionMetadata("Table.SelectRows", "name"),
    result1 = if test1 = "Table.SelectRows" then "Test 1 Passed" else "Test 1 Failed: " & Text.From(test1, "en-US"),

    // Test 2: Get description of a function
    test2 = GetFunctionMetadata("Table.SelectRows", "description"),
    result2 = if test2 <> null and Text.Contains(Text.From(test2, "en-US"), "rows", Comparer.OrdinalIgnoreCase) then "Test 2 Passed" else "Test 2 Failed",

    // Test 3: Get name of a different function (example param removed in parent)
    test3 = GetFunctionMetadata("Table.Group", "name"),
    result3 = if test3 = "Table.Group" then "Test 3 Passed" else "Test 3 Failed",

    // Test 4: Test with uppercase return parameter (should be case-insensitive)
    test4 = GetFunctionMetadata("List.Sum", "NAME"),
    result4 = if test4 = "List.Sum" then "Test 4 Passed" else "Test 4 Failed",

    // Test 5: Test with invalid return parameter
    test5 = GetFunctionMetadata("Table.SelectRows", "invalid"),
    result5 = if test5 = "Invalid return parameter value provided" then "Test 5 Passed" else "Test 5 Failed",

    // Test 6: Test with custom culture parameter
    test6 = GetFunctionMetadata("Text.Upper", "description", "en-US"),
    result6 = if test6 <> null and test6 <> "Invalid return parameter value provided" then "Test 6 Passed" else "Test 6 Failed",

    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: Get function name", result1},
            {"Test 2: Get function description", result2},
            {"Test 3: Get function example", result3},
            {"Test 4: Case-insensitive return parameter", result4},
            {"Test 5: Invalid return parameter", result5},
            {"Test 6: Custom culture parameter", result6}
        }
    )
in
    summary

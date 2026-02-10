let
    // Load the function from file
    SelectCase = Expression.Evaluate(Text.FromBinary(File.Contents("functions/Utils/SelectCase.pq")), #shared),
    
    // Test 1: Value matches first predicate
    test1 = SelectCase(5, {each _ < 10, "Less than 10", each _ >= 10, "10 or more"}, "No match"),
    result1 = if test1 = "Less than 10" then "Test 1 Passed" else "Test 1 Failed: " & Text.From(test1, "en-US"),
    
    // Test 2: Value matches second predicate
    test2 = SelectCase(15, {each _ < 10, "Less than 10", each _ >= 10, "10 or more"}, "No match"),
    result2 = if test2 = "10 or more" then "Test 2 Passed" else "Test 2 Failed",
    
    // Test 3: No matching predicate, return default
    test3 = SelectCase("test", {each _ = 123, "Is number", each _ = true, "Is boolean"}, "Unknown type"),
    result3 = if test3 = "Unknown type" then "Test 3 Passed" else "Test 3 Failed",
    
    // Test 4: Multiple predicates, returns first match
    test4 = SelectCase(100, {each _ > 50, "Greater than 50", each _ > 75, "Greater than 75", each _ = 100, "Exactly 100"}, "No match"),
    result4 = if test4 = "Greater than 50" then "Test 4 Passed" else "Test 4 Failed",
    
    // Test 5: Text comparison
    test5 = SelectCase("hello", {each Text.Length(_) > 10, "Long text", each Text.Length(_) <= 10, "Short text"}, "No match"),
    result5 = if test5 = "Short text" then "Test 5 Passed" else "Test 5 Failed",
    
    // Test 6: Boolean value
    test6 = SelectCase(true, {each _ = false, "Is false", each _ = true, "Is true"}, "No match"),
    result6 = if test6 = "Is true" then "Test 6 Passed" else "Test 6 Failed",
    
    // Summary table
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: First predicate matches", result1},
            {"Test 2: Second predicate matches", result2},
            {"Test 3: No match, return default", result3},
            {"Test 4: Multiple matches, returns first", result4},
            {"Test 5: Text comparison", result5},
            {"Test 6: Boolean value", result6}
        }
    )
in
    summary

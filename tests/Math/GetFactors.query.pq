let
    // Include function being tested
    GetFactors = (num as number) as list =>
        let
            // Function to generate factors of a number
            fnFactors = (x as number) as list =>
                List.Generate(
                    () as record => [f1 = 1, f2 = x, non_integer = true], 
                    each [f1] <= num, 
                    each [
                        f1     = [f1] + 1, 
                        f2     = x / ([f1] + 1), 
                        non_integer = Text.Contains(Text.From(x / ([f1] + 1), "en-US"), ".", Comparer.OrdinalIgnoreCase)
                    ]
                ), 
            
            // Select only integer factors
            sel = List.Select(fnFactors(num), each _[non_integer] = false), 
            
            // Convert the list of factors to a table
            converted = Table.FromList(sel, Splitter.SplitByNothing(), {"Factors"}, null, ExtraValues.Error), 
            
            // Expand the table to separate columns for each factor
            expanded = Table.ExpandRecordColumn(converted, "Factors", {"f1", "f2"}, {"f1", "f2"}), 
            
            // Combine and sort the factors
            result = List.Sort(List.Union({expanded[f1], expanded[f2]}), Order.Ascending)
        in
            result,
    
    // Test cases from Documentation.Examples
    Source = #table(
        {"TestCase", "Input", "Expected", "Actual", "Pass"},
        {
            {
                "Example 1: Factors of 28",
                28,
                {1, 2, 4, 7, 14, 28},
                GetFactors(28),
                GetFactors(28) = {1, 2, 4, 7, 14, 28}
            },
            {
                "Example 2: Factors of 100",
                100,
                {1, 2, 4, 5, 10, 20, 25, 50, 100},
                GetFactors(100),
                GetFactors(100) = {1, 2, 4, 5, 10, 20, 25, 50, 100}
            }
        }
    )
in
    Source

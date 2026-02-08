let
    // Include the function being tested
    NewRandomNumbers = (
        sample as number,
        seed as number,
        max as number
    ) as list =>
        let
            // Calculate the number of zeros needed based on the max value
            len = Text.Length(Text.From(max, "en-US")) - 1,
            
            // Generate zeros as text
            zeros = Text.Repeat("0", len),
            
            // Append zeros after a 1 and then convert to number
            places = Number.FromText("1" & zeros, "en-US"),

            // Generate random numbers
            generate = 
                // Select numbers less than or equal to max
                List.Select(
                    // Sort ascending
                    List.Sort(
                        // Get distinct numbers
                        List.Distinct(
                            // Generate random numbers and transform
                            List.Transform(
                                List.Random(sample, seed), 
                                // Convert to integers
                                each Number.RoundAwayFromZero(_ * places, 0)
                            )
                        ), 
                        Order.Ascending
                    ), 
                    each _ <= max
                )
        in  
            generate,
    
    // Test cases
    Source = #table(
        {"TestCase", "Sample", "Seed", "Max", "Expected", "Actual", "Pass"},
        {
            {
                "Generate random numbers up to 100 with seed 12345",
                10,
                12345,
                100,
                {7, 8, 17, 27, 51, 52, 74, 78, 80, 83},
                NewRandomNumbers(10, 12345, 100),
                NewRandomNumbers(10, 12345, 100) = {7, 8, 17, 27, 51, 52, 74, 78, 80, 83}
            }
        }
    )
in
    Source

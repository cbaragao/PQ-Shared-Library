// Test cases for ConvertTo-RoundedDateTime function
let
    // Include the function being tested (without type metadata)
    ConvertToRoundedDateTime = (dt as datetime, interval as number, optional culture as nullable text) as datetime =>
        let
            _culture = culture ?? "en-US",
            
            // Convert datetime to number
            Source = Number.From(dt, _culture), 
            
            // Calculate the number of intervals in a day
            Minutes = 24 * 60 / interval, 
            
            // Round the datetime to the nearest interval (use AwayFromZero for standard rounding)
            Rounded = Number.Round((Source * Minutes), 0, RoundingMode.AwayFromZero) / Minutes, 
            
            // Convert the rounded number back to datetime
            Result = DateTime.From(Rounded, _culture)
        in
            Result,
    
    // Test cases
    TestResults = #table(
        {"TestCase", "Input_DateTime", "Input_Interval", "Expected_Result", "Actual_Result", "Pass"},
        {
            {
                "Example from documentation",
                #datetime(2022, 10, 1, 10, 17, 55),
                15,
                #datetime(2022, 10, 1, 10, 15, 0),
                ConvertToRoundedDateTime(#datetime(2022, 10, 1, 10, 17, 55), 15),
                ConvertToRoundedDateTime(#datetime(2022, 10, 1, 10, 17, 55), 15) = #datetime(2022, 10, 1, 10, 15, 0)
            },
            {
                "Round up to 30 minutes",
                #datetime(2022, 10, 1, 10, 20, 0),
                30,
                #datetime(2022, 10, 1, 10, 30, 0),
                ConvertToRoundedDateTime(#datetime(2022, 10, 1, 10, 20, 0), 30),
                ConvertToRoundedDateTime(#datetime(2022, 10, 1, 10, 20, 0), 30) = #datetime(2022, 10, 1, 10, 30, 0)
            },
            {
                "Round down to 15 minutes",
                #datetime(2022, 10, 1, 10, 7, 0),
                15,
                #datetime(2022, 10, 1, 10, 0, 0),
                ConvertToRoundedDateTime(#datetime(2022, 10, 1, 10, 7, 0), 15),
                ConvertToRoundedDateTime(#datetime(2022, 10, 1, 10, 7, 0), 15) = #datetime(2022, 10, 1, 10, 0, 0)
            },
            {
                "Exact interval match",
                #datetime(2022, 10, 1, 10, 30, 0),
                15,
                #datetime(2022, 10, 1, 10, 30, 0),
                ConvertToRoundedDateTime(#datetime(2022, 10, 1, 10, 30, 0), 15),
                ConvertToRoundedDateTime(#datetime(2022, 10, 1, 10, 30, 0), 15) = #datetime(2022, 10, 1, 10, 30, 0)
            }
        }
    )
in
    TestResults

// Test cases for RoundDateTime function
let
    Source = #table(
        {"TestCase", "Input_DateTime", "Input_Interval", "Expected_Result", "Actual_Result", "Pass"},
        {
            {
                "Example from documentation",
                #datetime(2022, 10, 1, 10, 17, 55),
                15,
                #datetime(2022, 10, 1, 10, 15, 0),
                RoundDateTime(#datetime(2022, 10, 1, 10, 17, 55), 15),
                RoundDateTime(#datetime(2022, 10, 1, 10, 17, 55), 15) = #datetime(2022, 10, 1, 10, 15, 0)
            },
            {
                "Round up to 30 minutes",
                #datetime(2022, 10, 1, 10, 20, 0),
                30,
                #datetime(2022, 10, 1, 10, 30, 0),
                RoundDateTime(#datetime(2022, 10, 1, 10, 20, 0), 30),
                RoundDateTime(#datetime(2022, 10, 1, 10, 20, 0), 30) = #datetime(2022, 10, 1, 10, 30, 0)
            },
            {
                "Round down to 15 minutes",
                #datetime(2022, 10, 1, 10, 7, 0),
                15,
                #datetime(2022, 10, 1, 10, 0, 0),
                RoundDateTime(#datetime(2022, 10, 1, 10, 7, 0), 15),
                RoundDateTime(#datetime(2022, 10, 1, 10, 7, 0), 15) = #datetime(2022, 10, 1, 10, 0, 0)
            },
            {
                "Exact interval match",
                #datetime(2022, 10, 1, 10, 30, 0),
                15,
                #datetime(2022, 10, 1, 10, 30, 0),
                RoundDateTime(#datetime(2022, 10, 1, 10, 30, 0), 15),
                RoundDateTime(#datetime(2022, 10, 1, 10, 30, 0), 15) = #datetime(2022, 10, 1, 10, 30, 0)
            }
        }
    )
in
    Source

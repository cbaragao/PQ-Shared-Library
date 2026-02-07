let
    // Function being tested (self-contained)
    GetConfidenceInterval = (z as number, stdev as number, population as number, optional mode as nullable text) as record =>
      let
        // check optional parameter and default to s for sample
        m = mode ?? "s",

        // subtract 1 from population for samples and make that default
        n = if m = "p" then population else population - 1,

        // calculate output
        ci = z * (stdev / Number.Sqrt(n)),

        result = [positive = ci, negative = -ci]
      in
        result,
    
    // Test cases
    Source = #table(
        {"TestCase", "Input_z", "Input_stdev", "Input_population", "Input_mode", "Expected_positive", "Actual", "Actual_positive", "Actual_negative", "Pass"},
        {
            {
                "Sample mode (default) - Example 1",
                1.75,
                4,
                5000,
                null,
                0.09900485,
                GetConfidenceInterval(1.75, 4, 5000),
                GetConfidenceInterval(1.75, 4, 5000)[positive],
                GetConfidenceInterval(1.75, 4, 5000)[negative],
                // Check if values are approximately equal (within 0.00001)
                Number.Abs(GetConfidenceInterval(1.75, 4, 5000)[positive] - 0.09900485) < 0.00001
                and Number.Abs(GetConfidenceInterval(1.75, 4, 5000)[negative] - (-0.09900485)) < 0.00001
            },
            {
                "Population mode - Example 2",
                1.96,
                2.5,
                1000,
                "p",
                0.1549516,
                GetConfidenceInterval(1.96, 2.5, 1000, "p"),
                GetConfidenceInterval(1.96, 2.5, 1000, "p")[positive],
                GetConfidenceInterval(1.96, 2.5, 1000, "p")[negative],
                // Check if values are approximately equal (within 0.00001)
                Number.Abs(GetConfidenceInterval(1.96, 2.5, 1000, "p")[positive] - 0.1549516) < 0.00001
                and Number.Abs(GetConfidenceInterval(1.96, 2.5, 1000, "p")[negative] - (-0.1549516)) < 0.00001
            },
            {
                "Sample mode explicit",
                1.96,
                2.5,
                100,
                "s",
                0.4924685,
                GetConfidenceInterval(1.96, 2.5, 100, "s"),
                GetConfidenceInterval(1.96, 2.5, 100, "s")[positive],
                GetConfidenceInterval(1.96, 2.5, 100, "s")[negative],
                // Check if values are approximately equal (within 0.00001)
                Number.Abs(GetConfidenceInterval(1.96, 2.5, 100, "s")[positive] - 0.4924685) < 0.00001
                and Number.Abs(GetConfidenceInterval(1.96, 2.5, 100, "s")[negative] - (-0.4924685)) < 0.00001
            }
        }
    )
in
    Source

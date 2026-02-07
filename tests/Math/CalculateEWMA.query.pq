let
    // Include the function being tested
    CalculateEWMA = (
        alpha as number,
        values as list,
        index as number
    ) as number =>
        let
            // Accumulate EWMA values up to the specified index
            resultList = List.Accumulate(
                List.FirstN(values, index + 1),
                {},
                (state as list, current as number) as list =>
                    if List.Count(state) = 0 then
                        {current}
                    else
                        state & {
                            alpha * current + (1 - alpha) * List.Last(state)
                        }
            ),
            result = resultList{index}
        in
            result,

    // Test cases
    Source = #table(
        {"TestCase", "Alpha", "Values", "Index", "Expected", "Actual", "Pass"},
        {
            {
                "Standard EWMA at index 4 with alpha=0.3",
                0.3,
                {10, 12, 15, 11, 13},
                4,
                12.0508,
                Number.Round(CalculateEWMA(0.3, {10, 12, 15, 11, 13}, 4), 4, RoundingMode.AwayFromZero),
                Number.Round(CalculateEWMA(0.3, {10, 12, 15, 11, 13}, 4), 4, RoundingMode.AwayFromZero) = 12.0508
            },
            {
                "High alpha (responsive) at index 2",
                0.7,
                {100, 110, 105, 115, 108},
                2,
                105.6,
                Number.Round(CalculateEWMA(0.7, {100, 110, 105, 115, 108}, 2), 4, RoundingMode.AwayFromZero),
                Number.Round(CalculateEWMA(0.7, {100, 110, 105, 115, 108}, 2), 4, RoundingMode.AwayFromZero) = 105.6
            },
            {
                "First index returns first value unchanged",
                0.5,
                {25, 30, 28, 32},
                0,
                25,
                Number.Round(CalculateEWMA(0.5, {25, 30, 28, 32}, 0), 4, RoundingMode.AwayFromZero),
                Number.Round(CalculateEWMA(0.5, {25, 30, 28, 32}, 0), 4, RoundingMode.AwayFromZero) = 25
            },
            {
                "Low alpha (smooth) at index 3",
                0.2,
                {50, 55, 60, 52, 58},
                3,
                52.64,
                Number.Round(CalculateEWMA(0.2, {50, 55, 60, 52, 58}, 3), 4, RoundingMode.AwayFromZero),
                Number.Round(CalculateEWMA(0.2, {50, 55, 60, 52, 58}, 3), 4, RoundingMode.AwayFromZero) = 52.64
            }
        }
    )
in
    Source

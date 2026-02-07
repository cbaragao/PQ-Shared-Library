let
  CalculateEWMA = (
    alpha as number,
    values as list,
    index as number
  ) as number =>
    let
      // Accumulate EWMA values up to the specified index
      resultList = List.Accumulate(
        List.FirstN(values, index + 1), // take values up to and including the current index
        {}, // initial state: empty list
        (state as list, current as number) as list =>
          if List.Count(state) = 0 then
            {current} // first EWMA is just the first value
          else
            state & {
              alpha * current + (1 - alpha) * List.Last(state)
            } // recursive EWMA formula
      ),
      result = resultList{index} // return the EWMA value at the specified index
    in
      result,

  fnType = type function (alpha as number, values as list, index as number) as number
    meta [
      Documentation.Name = "CalculateEWMA",
      Documentation.LongDescription = "Computes the Exponential Weighted Moving Average (EWMA) for a list of numeric values using a smoothing factor alpha. The function builds an EWMA series up to the specified index using List.Accumulate and returns the EWMA value at that index. The first EWMA equals the first value in the list.<br/><br/>Parameters:<br/>• alpha (number): Smoothing factor between 0 and 1 (higher values give more weight to recent observations)<br/>• values (list): List of numeric values to calculate EWMA for<br/>• index (number): Zero-based index position to return EWMA value for<br/><br/>Returns the EWMA value at the specified index position.",
      Documentation.Examples = {
        [
          Description = "Calculate EWMA at index 4 for a simple list with alpha=0.3 (gives 30% weight to current value, 70% to previous EWMA)",
          Code = "CalculateEWMA(0.3, {10, 12, 15, 11, 13}, 4)",
          Result = "12.0508"
        ],
        [
          Description = "Calculate EWMA at index 2 with higher alpha=0.7 (more responsive to recent changes)",
          Code = "CalculateEWMA(0.7, {100, 110, 105, 115, 108}, 2)",
          Result = "105.6"
        ],
        [
          Description = "Calculate EWMA at first index (index 0) returns the first value unchanged",
          Code = "CalculateEWMA(0.5, {25, 30, 28, 32}, 0)",
          Result = "25"
        ]
      }
    ]
in
  Value.ReplaceType(CalculateEWMA, fnType)
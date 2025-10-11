let
    fnExponentialWeightedMovingAverage =
    Function.From(
        type function(alpha as number, values as list, index as number) as number,
        (params) =>
            let
                alpha = params{0},
                values = params{1},
                index = params{2},
                // Accumulate EWMA values up to the specified index
                resultList = List.Accumulate(
                    List.FirstN(values, index + 1), // take values up to and including the current index
                    {}, // initial state: empty list
                    (state, current) =>
                        if List.Count(state) = 0 then
                            {current} // first EWMA is just the first value
                        else
                            state & {
                                alpha * Number.From(current) + (1 - alpha) * Number.From(List.Last(state))
                            } // recursive EWMA formula
                ),
                result = resultList{index} // return the EWMA value at the specified index
            in
                result
    ),

    fnType = type function (alpha as number, values as list, index as number) as number
        meta [
            Documentation.Name = "fnExponentialWeightedMovingAverage",
            Documentation.LongDescription = "Computes the EWMA for a list of numeric values using a smoothing factor alpha. The function builds an EWMA series up to the supplied index using List.Accumulate and returns the EWMA value at that index. The first EWMA equals the first value in the list."
            ],

    EWMAFunction = Value.ReplaceType(fnExponentialWeightedMovingAverage, fnType)
in
    EWMAFunction
let
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
  
  fnType = type function (z as number, stdev as number, population as number, optional mode as nullable text) as record
    meta [
      Documentation.Name = "Get-ConfidenceInterval",
      Documentation.LongDescription = "Calculates the confidence interval range based on z-score, standard deviation, and population size. The optional mode parameter determines whether to calculate for a sample (""s"", default) or population (""p""). Returns a record with positive and negative confidence interval values.",
      Documentation.Examples = {
        [
          Description = "Calculate confidence interval for a sample with z=1.75, stdev=4, population=5000",
          Code = "Get-ConfidenceInterval(1.75, 4, 5000)",
          Result = "[positive = 0.09900485, negative = -0.09900485]"
        ],
        [
          Description = "Calculate confidence interval for entire population",
          Code = "Get-ConfidenceInterval(1.96, 2.5, 1000, ""p"")",
          Result = "[positive = 0.1549516, negative = -0.1549516]"
        ]
      }
    ]
in
  Value.ReplaceType(GetConfidenceInterval, fnType)
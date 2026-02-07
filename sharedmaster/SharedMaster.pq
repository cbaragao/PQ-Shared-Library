let
  return = Table.FromRecords(
    {
      [
        Name = "RoundDateTime", 
        Category = "DateTime", 
        Function = let
  RoundDateTime= Function.From(
    type function (dt as datetime, interval as number) as datetime, 
    (params) =>
      let
        // Convert datetime to number
        Source = Number.From(params{0}), 
        
        // Calculate the number of intervals in a day
        Minutes = 24 * 60 / params{1}, 
        
        // Round the datetime to the nearest interval
        Rounded = Number.RoundAwayFromZero((Source * Minutes), 0) / Minutes, 
        
        // Convert the rounded number back to datetime
        Result = DateTime.From(Rounded)
      in
        Result
  ), 
  fnType = type function (dt as datetime, interval as number) as datetime
    meta [
      Documentation.Name = "RoundDateTime", 
      Documentation.LongDescription = "This function rounds a datetime to a specified minute interval (e.g., round to the nearest 15 minutes).", 
      Documentation.Examples = {
        [
          Description = "Round a datetime to the nearest 15 minutes.",
          Code        = "=RoundDateTime(#datetime(2022, 10, 1, 10, 17, 55), 15)", 
          Result      = "#datetime(2022, 10, 1, 10, 15, 0)"
        ]
      }
    ]
in
  Value.ReplaceType(RoundDateTime, fnType)

      ],
      [
        Name = "Bearing", 
        Category = "Geo", 
        Function = let
  Bearing = Function.From(
    type function (lat1_rad as number, lat2_rad as number, lon1_rad as number, lon2_rad as number) as record, 
    (params) =>
      let
        // Calculate the initial bearing from the start point to the end point
        Source = Number.Atan2(
          Number.Sin(params{3} - params{2}) * Number.Cos(params{1}),
          Number.Cos(params{0}) * Number.Sin(params{1}) - Number.Sin(params{0}) * Number.Cos(params{1}) * Number.Cos(params{3} - params{2})
        ),
        
        // Convert the bearing from radians to degrees
        FromRadians = Source * (180 / Number.PI),
        
        // Correct negative bearings by adding 360 and taking modulo 360
        CorrectNegative = Number.Mod(FromRadians + 360, 360),
        
        // Round the bearing to the nearest whole number
        Round = Number.RoundUp(CorrectNegative),
        
        // Determine the compass direction based on the rounded bearing
        DirectionResult =
          if Round <= 11 or Round >= 349 then [Direction = "N", Sort = 1]
          else if Round <= 33 then [Direction = "NNE", Sort = 2]
          else if Round <= 55 then [Direction = "NE", Sort = 3]
          else if Round <= 77 then [Direction = "ENE", Sort = 4]
          else if Round <= 99 then [Direction = "E", Sort = 5]
          else if Round <= 121 then [Direction = "ESE", Sort = 6]
          else if Round <= 143 then [Direction = "SE", Sort = 7]
          else if Round <= 166 then [Direction = "SSE", Sort = 8]
          else if Round <= 189 then [Direction = "S", Sort = 9]
          else if Round <= 212 then [Direction = "SSW", Sort = 10]
          else if Round <= 234 then [Direction = "SW", Sort = 11]
          else if Round <= 256 then [Direction = "WSW", Sort = 12]
          else if Round <= 279 then [Direction = "W", Sort = 13]
          else if Round <= 302 then [Direction = "WNW", Sort = 14]
          else if Round <= 325 then [Direction = "NW", Sort = 15]
          else if Round >= 348 then [Direction = "NNW", Sort = 16]
          else [Direction = "UNK", Sort = -1]
      in
        DirectionResult
  ), 
  fnType = type function (lat1_rad as number, lat2_rad as number, lon1_rad as number, lon2_rad as number) as record
    meta [
      Documentation.Name = "Bearing", 
      Documentation.LongDescription
        = "This function calculates the compass direction from one geographic coordinate to another. It takes the latitude and longitude of two points in radians and returns the compass direction as a record with the direction and sort order.", 
      Documentation.Examples = {
        [
          Description = "Calculate the direction from point A to point B.",
          Code        = "=Bearing(0.785398, 0.523599, -1.5708, -1.0472)", 
          Result      = "[Direction = 'ESE', Sort = 6]"
        ]
      }
    ]
in
  Value.ReplaceType(Bearing, fnType)
      ],
      [
        Name = "CalculateDistance", 
        Category = "Geo", 
        Function = let
  CalculateDistance = Function.From(
    type function (lat1 as number, lon1 as number, lat2 as number, lon2 as number, optional measure as number) as number, 
    (params) =>
      let
        // Calculate the difference in latitude and longitude in radians
        dLat = (params{2} - params{0}) * Number.PI / 180.0,
        dLon = (params{3} - params{1}) * Number.PI / 180.0,

        // Convert latitudes to radians
        latitude1 = params{0} * Number.PI / 180.0,
        latitude2 = params{2} * Number.PI / 180.0,

        // Apply the Haversine formula
        a = (Number.Power(Number.Sin(dLat / 2), 2) + 
             Number.Power(Number.Sin(dLon / 2), 2) * 
             Number.Cos(latitude1) * Number.Cos(latitude2)),

        // Determine the radius of the Earth: 6371 km or 3961 miles
        r = if params{4} = 1 then 3961 else 6371,
        c = 2 * Number.Asin(Number.Sqrt(a)),

        // Calculate the distance and round to 4 decimal places
        result = Number.RoundAwayFromZero(r * c, 4)
      in
        result
  ), 
  fnType = type function (lat1 as number, lon1 as number, lat2 as number, lon2 as number, optional measure as number) as number
    meta [
      Documentation.Name = "CalculateDistance", 
      Documentation.LongDescription
        = "This function calculates the distance between two geographic coordinates using the Haversine formula. " & "takes the latitude and longitude of two points and returns the distance in kilometers by default, or " &"in miles if specified.", 
      Documentation.Examples = {
        [
          Description = "Calculate the distance between two points in kilometers.",
          Code        = "=CalculateDistance(34.0522, -118.2437, 40.7128, -74.0060)", 
          Result      = "3935.7463"
        ],
        [
          Description = "Calculate the distance between two points in miles.",
          Code        = "=CalculateDistance(34.0522, -118.2437, 40.7128, -74.0060, 1)", 
          Result      = "2446.9457"
        ]
      }
      ]
in
  Value.ReplaceType(CalculateDistance, fnType)
      ],
      [
        Name = "Benford", 
        Category = "Math", 
        Function = let Benford = 
    Function.From(type function(num as number) as record,(params)=>
        let
            len = Text.Length(Text.From(params{0})),
            first  = if len >=1 then Number.From(Text.ToList(Text.From(params{0})){0}) else null, 
            second = if len >= 2 then Number.From(Text.ToList(Text.From(params{0})){1}) else null, 
            third  = if len >=3 then Number.From(Text.ToList(Text.From(params{0})){2}) else null, 
            d1     = try Number.Log10(1 + (1 / first)) otherwise null, 
            d2     = try Number.Log10(1 + (1 / ((10 * first) + second))) otherwise null, 
            d3     = try Number.Log10(1 + (1 / ((100 * first) + (10 * second) + third))) otherwise null, 
            return = [Digit_One = d1, Digit_Two = d2, Digit_Three = d3]
        in
            return),
  fnType = type function (num as number) as record
    meta [
      Documentation.Name = "Benford",
      Documentation.LongDescription = "This provides a Benford analysis for (up to) the first three digits of a number."
    ]
in
  Value.ReplaceType(Benford, fnType)
      ],
      [
        Name = "Conf", 
        Category = "Math", 
        Function = let Conf = 
 Function.From(type function(z as number, stdev as number, population as number, optional mode as text) as record, (params)=>

let
  
  // check optional parameter and default to s for sample
  m = if params{3} = null then "s" else params{3},

  // subtract 1 from population for samples and make that default
  n = if m = "p" then params{2} else params{2} -1,

  // calculate output
  ci = params{0} * (params{1} / Number.Sqrt(n))

in

  [positive = ci, negative = -ci]),
  
  fnType = type function (z as number, stdev as number, population as number, optional mode as text) as record
    meta [
      Documentation.Name = "Conf",
      Documentation.LongDescription = "This takes parameters and provides the confidence interval range.",
      Documentation.Examples = {
    [Description = "Based on z-score, standard deviation, population, and optional mode (""s"" for sample, ""p"" for population), this generates a confidence interval.",
    Code = "=Conf(1.75, 4, 5000, null)",
    Result="[positive=0.09900485, negative=-0.09900485]"]
}]
      

in
  Value.ReplaceType(Conf, fnType)
      ],
      [
        Name = "Corr", 
        Category = "Math", 
        Function = let
  Corr = Function.From(
    type function (t as table) as table, 
    (params) =>
      let
        correlation = (x as list, y as list) =>
          let
            x1 = List.Transform(x, each Number.From(_)), 
            y1 = List.Transform(y, each Number.From(_)), 
            sum_x = List.Sum(x1), 
            sum_y = List.Sum(y1), 
            sum_x_sq = List.Accumulate(
              x1, 
              0, 
              (state, current) => Number.From(state) + Number.Power(Number.From(current), 2)
            ), 
            sum_y_sq = List.Accumulate(
              y1, 
              0, 
              (state, current) => Number.From(state) + Number.Power(Number.From(current), 2)
            ), 
            sum_xy = 
              let
                l   = List.Zip({x1, y1}), 
                tx  = List.Transform(l, each _{0} * _{1}), 
                sum = List.Sum(tx)
              in
                sum, 
            n = List.Count(x1), 
            r = ((n * sum_xy) - (sum_x * sum_y))
              / Number.Sqrt(
                (n * sum_x_sq - Number.Power(sum_x, 2)) * (n * sum_y_sq - Number.Power(sum_y, 2))
              )
          in
            r, 
        vars = Table.RenameColumns(
          Table.TransformColumnTypes(
            Table.FromList(Table.SelectRows(Table.Schema(params{0}), each _[Kind] = "number")[Name]), 
            {"Column1", type text}
          ), 
          {"Column1", "Vars"}
        ), 
        add_vars = Table.AddColumn(vars, "variables", each vars), 
        expand_vars = Table.ExpandTableColumn(add_vars, "variables", {"Vars"}, {"Vars.1"}), 
        rename = Table.RenameColumns(expand_vars, {{"Vars", "Var1"}, {"Vars.1", "Var2"}}), 
        sel = Table.SelectRows(
          Table.TransformColumnTypes(rename, {{"Var2", type text}}), 
          each _[Var1] <> _[Var2]
        ), 
        corr = Table.AddColumn(
          sel, 
          "Corr", 
          each correlation(
            Table.ToList(
              Table.TransformColumnTypes(
                Table.SelectColumns(params{0}, [Var1]), 
                {[Var1], type text}
              )
            ), 
            Table.ToList(
              Table.TransformColumnTypes(
                Table.SelectColumns(params{0}, [Var2]), 
                {[Var2], type text}
              )
            )
          )
        ), 
        sort = Table.Sort(corr, {{"Var1", Order.Ascending}, {"Var2", Order.Ascending}}), 
        pivot = Table.Pivot(sort, List.Distinct(sort[Var2]), "Var2", "Corr"), 
        numcols = Table.SelectRows(Table.Schema(pivot), each _[Kind] <> "text")[Name], 
        types = Table.TransformColumnTypes(
          pivot, 
          List.Zip({numcols, List.Repeat({type number}, List.Count(numcols))})
        ), 
        replace_ones = Table.ReplaceValue(types, null, 1, Replacer.ReplaceValue, numcols), 
        reorder = Table.ReorderColumns(replace_ones, List.Combine({{"Var1"}, replace_ones[Var1]}))
      in
        reorder
  ), 
  fnType = type function (t as table) as table
    meta [
      Documentation.Name = "Corr", 
      Documentation.LongDescription
        = "This function takes a table and generates a Correlation Matrix table.", 
      Documentation.Examples = {
        [
          Description = "This provides a correlation matrix based on table t.", 
          Code        = "=Corr(Source)", 
          Result      = "Correlation matrix table based on number columns in table passed in."
        ]
      }
    ]
in
  Value.ReplaceType(Corr, fnType)
      ],
      [
        Name = "ErlangC", 
        Category = "Math", 
        Function = let 
  ErlangC = 
Function.From( type function
  (
    number_of_calls as number, 
    period_of_minutes as number, 
    average_handling_time as number, 
    required_service_level as number, 
    target_answer_time as number,
    maximum_occupancy as number, 
    shrinkage as number
  ) as record, (params) =>
    let
      // define probability of waiting function
      fnProbWait = (num_agents as number, traffic_intensity as number) =>
        let
          a_n = Number.Power(traffic_intensity, num_agents), 
          X = a_n / Number.Factorial(num_agents) * (num_agents / (num_agents - traffic_intensity)), 
          Y = List.Accumulate(
            {0 .. (num_agents - 1)}, 
            0, 
            (state, current) =>
              state + Number.Power(traffic_intensity, current) / Number.Factorial(current)
          ), 
          Pw = X / (Y + X)
        in
          Pw, 
      // define service level function
      fnServiceLevel = (
        num_agents as number, 
        traffic_intensity as number, 
        prob_waiting as number, 
        tat as number, 
        aht as number
      ) =>
        let
          ServiceLevel = 1
            - (prob_waiting * Number.Exp(- (num_agents - traffic_intensity) * (tat / aht)))
        in
          ServiceLevel, 
      
      // determine calls per hour
      calls_per_hour = params{0} * 60 / params{1}, 
      
      // determine the traffic intensity (A)
      A = calls_per_hour * params{2} / 3600, 
      
      // determine the number of agents (N) - start with A + 1 
      N = A + 1, 

      // raise A to the power of N
      A_N = Number.Power(A, N), 

      // determine the probability of waiting
      Pw = fnProbWait(N, A), 

      // determine the service level
      SL = fnServiceLevel(N, A, Pw, params{4}, params{2}), 

      // iterate until you are N-1 from the target number of agents
      Iterate = List.Generate(
        () => [Agents = N, Service_Level = SL], 
        each [Service_Level] < params{3}, 
        each [
          Agents = [Agents] + 1, 
          Service_Level = fnServiceLevel(
            [Agents] + 1, 
            A, 
            fnProbWait([Agents] + 1, A), 
            params{4}, 
            params{2}
          )
        ]
      ), 

      // figure out N-1 so you can generate the result next
      Last = List.LastN(Iterate, 1){0}[Agents], 
      
      
      // generate the result
      Output = [
        Agents = Last + 1, 
        Service_Level = fnServiceLevel(
          Last + 1, 
          A, 
          fnProbWait(Last + 1, A), 
          params{4}, 
          params{2}
        ),
        Occupancy = if A/(Last+1) > params{5} then A/(A/(Last+1)/100) else A/(Last+1),
        Shrinkage = (Last+1)/(1-(params{6}))
      ]
    in

      Output),


fnType = type function (    
    number_of_calls as number, 
    period_of_minutes as number, 
    average_handling_time as number, 
    required_service_level as number, 
    target_answer_time as number,
    maximum_occupancy as number,
    shrinkage as number) 
    as record meta 
[Documentation.Name = "ErlangC",
Documentation.LongDescription = "This calculates the probable amount of agents needed to meet the required service level and the probable service level for that number of agents in a record.",
Documentation.Examples = {
    [Description = "This provides an answer for the following parameters: " &
                    "Number of Calls = 100; " &
                    "Period of Minutes = 30; " &
                    "Average Handling Time (Seconds) = 180; " &
                    "Required Service Level (% expressed as decimal) = .80; " &
                    "Target Answer Time (Seconds) = 20; ",
    Code = "pqmath.ErlangC(100, 30, 180, 0.8, 20)",
    Result="[Agents = 14, Service_Level = 0.888350019]"]
}]
    in  
Value.ReplaceType(ErlangC, fnType)
      ],
      [
        Name = "fnExponentialWeightedMovingAverage", 
        Category = "Math", 
        Function = let
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
      ],
      [
        Name = "GenerateRandomNumbers", 
        Category = "Math", 
        Function = let
  GenerateRandomNumbers = Function.From(
    type function (sample as number, seed as number, max as number) as list, 
    (params) =>
      let
        // Calculate the number of zeros needed based on the max value
        len = Text.Length(Text.From(params{2})) - 1,
        
        // Generate zeros as text
        zeros = Text.Repeat("0", len),
        
        // Append zeros after a 1 and then convert to number
        places = Number.FromText("1" & zeros),

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
                  List.Random(params{0}, params{1}), 
                  // Convert to integers
                  each Number.RoundAwayFromZero(_ * places, 0)
                )
              ), 
              Order.Ascending
            ), 
            each _ <= params{2}
          )
      in  
        generate
  ), 
  fnType = type function (sample as number, seed as number, max as number) as list
    meta [
      Documentation.Name = "GenerateRandomNumbers", 
      Documentation.LongDescription = "This function generates a list of random numbers up to a specified maximum value. It takes the sample size, seed, and maximum value as inputs and returns a sorted list of distinct random numbers.",
      Documentation.Examples = {
        [
          Description = "Generate a list of random numbers up to 100.",
          Code        = "=GenerateRandomNumbers(10, 12345, 100)", 
          Result      = "{7, 17, 26, 51, 74, 77, 80, 83}"
        ]
      }
    ]
in
  Value.ReplaceType(GenerateRandomNumbers, fnType)
      ],
      [
        Name = "GetFactors", 
        Category = "Math", 
        Function = let
  GetFactors = Function.From(
    type function (num as number) as list, 
    (params) =>
      let
        // Function to generate factors of a number
        fnFactors = (x as number) =>
          List.Generate(
            () => [f1 = 1, f2 = x, non_integer = true], 
            each [f1] <= params{0}, 
            each [
              f1     = [f1] + 1, 
              f2     = x / ([f1] + 1), 
              non_integer = Text.Contains(Text.From(x / ([f1] + 1)), ".")
            ]
          ), 
        
        // Select only integer factors
        sel = List.Select(fnFactors(params{0}), each _[non_integer] = false), 
        
        // Convert the list of factors to a table
        converted = Table.FromList(sel, Splitter.SplitByNothing(), {"Factors"}, null, ExtraValues.Error), 
        
        // Expand the table to separate columns for each factor
        expanded = Table.ExpandRecordColumn(converted, "Factors", {"f1", "f2"}, {"f1", "f2"}), 
        
        // Combine and sort the factors
        return = List.Sort(List.Union({expanded[f1], expanded[f2]}), Order.Ascending)
      in
        return
  ), 
  fnType = type function (num as number) as list
    meta [
      Documentation.Name = "GetFactors", 
      Documentation.LongDescription = "This function generates and returns a sorted list of all factors of a given number.",
      Documentation.Examples = {
        [
          Description = "Get the factors of 28.",
          Code        = "=GetFactors(28)", 
          Result      = "{1, 2, 4, 7, 14, 28}"
        ]
      }
    ]
in
  Value.ReplaceType(GetFactors, fnType)
      ],
      [
        Name = "MegaAverage", 
        Category = "Math", 
        Function = let
  MegaAverage = 
    Function.From(
        type function(l as list) as record, (params)=>

        let
            // function for trimmed average
            fnGetTrimmed = 
                (lst as list)=>
                let
                    // figure out 1st and 3rd quartiles
                    Percentile = List.Percentile(lst, {0.25, 0.75}, [PercentileMode=PercentileMode.ExcelInc]),

                    // get the interquartile range
                    IQR = Percentile{1} - Percentile{0},

                    // get the upper limit
                    Upper = Percentile{1} + (1.5 * IQR),

                    // get the lower limit
                    Lower = Percentile{0} - (1.5 * IQR),

                    // trim outliers
                    Select = List.Select(lst, each _ < Upper and _ > Lower),

                    // get the average of the rest
                    Trimmed =  List.Average(Select)

                in

                    Trimmed,
            
            fnGetGeomAvg = 

                // function for the geometric average
                (lst as list, n as number)=>

                let

                    // get the natural log of each number
                    log = List.Transform(lst, each Number.Ln(_)),

                    // take the average, then apply Number.Exp
                    log_avg = Number.Exp(List.Sum(log)/ n )

                in  

                    log_avg,
            
            fnGetWinsorAvg = 

                // function for winsorized average 
                (lst as list)=>

                let 

                    // get the 0.05 and 0.95 percentiles
                    pcntl = List.Percentile(lst, {0.05, 0.95}, [PercentileMode=PercentileMode.ExcelInc]),

                    // if the values are outside of these percentiles, replace them
                    replace = List.Transform(lst, each if _ < pcntl{0} then pcntl{0} else if _ > pcntl{1} then pcntl{1} else _),

                    // take the average of the list with replacements
                    winsor_avg = List.Average(replace)
                in   
                    winsor_avg,
            
            fnGetHarmonicAvg = 

                // function for harmonic mean
                (lst as list, n as number)=>

                let 

                    // convert each value to reciprocals
                    reciprocals = List.Transform(lst, each 1/_),

                    // sum the reciprocals
                    sum_reciprocals = List.Sum(reciprocals),

                    // divide the sum by the count
                    harmonic = n / sum_reciprocals
                in   
                    harmonic,

            // call the functions
            count = List.Count(params{0}),
            arith = List.Average(params{0}),
            med = List.Median(params{0}),
            trim = fnGetTrimmed(params{0}),
            geom = fnGetGeomAvg(params{0}, count),
            wins = fnGetWinsorAvg(params{0}),
            harm = fnGetHarmonicAvg(params{0}, count)
        in    

            // return as a record
            [
                arithmetic = arith, 
                median = med, 
                trimmed = trim, 
                geometric = geom, 
                winsor = wins, 
                harmonic = harm,
                usage = "Median: Consider when the data is skewed and there are outliers present  #(lf)" &
                        "Trimmed: Consider using when you want to minimize standard error in a dataset with small deviations from normality #(lf)" &
                        "Geometric: Consider when numbers are positive, exponential, and meant to be multiplied together. Example: Average growth rate, interest rates. #(lf)" &
                        "Winsor: Consider using when outliers are present and you want to limit their effect #(lf)" &
                        "Harmonic: Consider using on ratios or fractions, like miles per hour #(lf)"
            ]),
  
  fnType = type function (l as list) as record
    meta [
      Documentation.Name = "MegaAverage",
      Documentation.LongDescription = "This function operates on a list and calculates the arithmetic mean, median, trimmed mean, geometric mean, winsorized mean, and harmonic mean.",
      Documentation.Examples = {
    [Description = "This provides the different values for an example list.",
    Code = "MegaAverage({1, 5, 20, 40, 80, 200})",
    Result="[arithmetic = 57.67, median = 30, trimmed = 29.2, geometric = 20, winsor = 52.83, harmonic= 4.64]"]
}]

in
  Value.ReplaceType(MegaAverage, fnType)
      ],
      [
        Name = "MegaStDevS", 
        Category = "Math", 
        Function = let
  MegaStDevS = 
    Function.From(
        type function(l as list) as record, (params)=>

        let
            // function for trimmed average
            fnGetTrimmed = 
                (lst as list)=>
                let
                    // figure out 1st and 3rd quartiles
                    Percentile = List.Percentile(lst, {0.25, 0.75}, [PercentileMode=PercentileMode.ExcelInc]),

                    // get the interquartile range
                    IQR = Percentile{1} - Percentile{0},

                    // get the upper limit
                    Upper = Percentile{1} + (1.5 * IQR),

                    // get the lower limit
                    Lower = Percentile{0} - (1.5 * IQR),

                    // trim outliers
                    Select = List.Select(lst, each _ < Upper and _ > Lower),

                    // get the average of the rest
                    Trimmed =  List.Average(Select)

                in

                    Trimmed,
            
            fnGetGeomAvg = 

                // function for the geometric average
                (lst as list, n as number)=>

                let

                    // get the natural log of each number
                    log = List.Transform(lst, each Number.Ln(_)),

                    // take the average, then apply Number.Exp
                    log_avg = Number.Exp(List.Sum(log)/ n )

                in  

                    log_avg,
            
            fnGetWinsorAvg = 

                // function for winsorized average 
                (lst as list)=>

                let 

                    // get the 0.05 and 0.95 percentiles
                    pcntl = List.Percentile(lst, {0.05, 0.95}, [PercentileMode=PercentileMode.ExcelInc]),

                    // if the values are outside of these percentiles, replace them
                    replace = List.Transform(lst, each if _ < pcntl{0} then pcntl{0} else if _ > pcntl{1} then pcntl{1} else _),

                    // take the average of the list with replacements
                    winsor_avg = List.Average(replace)
                in   
                    winsor_avg,
            
            fnGetHarmonicAvg = 

                // function for harmonic mean
                (lst as list, n as number)=>

                let 

                    // convert each value to reciprocals
                    reciprocals = List.Transform(lst, each 1/_),

                    // sum the reciprocals
                    sum_reciprocals = List.Sum(reciprocals),

                    // divide the sum by the count
                    harmonic = n / sum_reciprocals
                in   
                    harmonic,
            
            fnStDevSample = 
            
                // function to manually calculate the standard deviation for a sample population
                (lst as list, rcd as text, degrees as number) =>

                let 
                    stdev = Number.Sqrt(
                                List.Sum(
                                    List.Transform(
                                        lst, 
                                        each Record.Field(_,rcd)
                                    )
                                )
                                / degrees
                            )
                in   
                    stdev,

            // call the functions
            count = List.Count(params{0}),
            arith = List.Average(params{0}),
            trim = fnGetTrimmed(params{0}),
            geom = fnGetGeomAvg(params{0}, count),
            wins = fnGetWinsorAvg(params{0}),
            harm = fnGetHarmonicAvg(params{0}, count),
            dof = count -1,
            loop = 
                List.Generate(
                    ()=>[
                        i = 0, 
                        a = Number.Power(params{0}{0} - arith, 2),
                        t = Number.Power(params{0}{0} - trim, 2),
                        g = Number.Power(params{0}{0} - geom, 2),
                        w = Number.Power(params{0}{0} - wins, 2),
                        h = Number.Power(params{0}{0} - harm, 2)    
                    ], 
                    each [i] <= dof, 
                    each [
                        i=[i]+1,
                        a = Number.Power(params{0}{[i]+1} - arith, 2),
                        t = Number.Power(params{0}{[i]+1} - trim, 2),
                        g = Number.Power(params{0}{[i]+1} - geom, 2),
                        w = Number.Power(params{0}{[i]+1} - wins, 2),
                        h = Number.Power(params{0}{[i]+1} - harm, 2)    
                        ])
        in    
            // return as a record
           [
                arithmetic = List.StandardDeviation(params{0}),
                trimmed = fnStDevSample(loop, "t", dof), 
                geometric = fnStDevSample(loop, "g", dof), 
                winsor = fnStDevSample(loop, "w", dof), 
                harmonic = fnStDevSample(loop, "h", dof),
                usage = "Arithmetic: Standard deviation for sample population based on arithmetic mean #(lf)" &
                        "Trimmed: Consider using when you want to minimize standard error in a dataset with small deviations from normality #(lf)" &
                        "Geometric: Consider when numbers are positive, exponential, and meant to be multiplied together. Example: Average growth rate, interest rates. #(lf)" &
                        "Winsor: Consider using when outliers are present and you want to limit their effect #(lf)" &
                        "Harmonic: Consider using on ratios or fractions, like miles per hour #(lf)"
            ]),
  
  fnType = type function (l as list) as record
    meta [
      Documentation.Name = "MegaStDevSample",
      Documentation.LongDescription = "This function operates on a list and calculates different means and uses those means as part of a sample standard deviation calculation.",
      Documentation.Examples = {
    [Description = "This provides the different values for an example list.",
    Code = "= MegaStDevSample({1, 5, 10, 20, 22})",
    Result="[arithmetic = 9.18, trimmed = 9.18, geometric = 10.32, winsor = 9.18, harmonic= 12.83]"]
}]
      

in
  Value.ReplaceType(MegaStDevS, fnType)
      ],
      [
        Name = "Pearson", 
        Category = "Math", 
        Function = let
  Pearson= Function.From(
    type function (x as list, y as list) as number, 
    (params) =>
      let
        // Calculate the sum of list x
        sum_x = List.Sum(params{0}),
        
        // Calculate the sum of list y
        sum_y = List.Sum(params{1}),
        
        // Calculate the sum of squares of list x
        sum_x_sq = List.Accumulate(params{0}, 0, (state, current) => state + Number.Power(current, 2)),
        
        // Calculate the sum of squares of list y
        sum_y_sq = List.Accumulate(params{1}, 0, (state, current) => state + Number.Power(current, 2)),
        
        // Calculate the sum of products of corresponding elements in lists x and y
        sum_xy = 
          let   
            l = List.Zip({params{0}, params{1}}),
            tx = List.Transform(l, each _{0} * _{1}),
            sum = List.Sum(tx)
          in 
            sum,
        
        // Calculate the number of elements in list x
        n = List.Count(params{0}),
        
        // Calculate the Pearson correlation coefficient
        Result = ((n * sum_xy) - (sum_x * sum_y)) / 
            Number.Sqrt((n * sum_x_sq - Number.Power(sum_x, 2)) * (n * sum_y_sq - Number.Power(sum_y, 2)))
      in
        Result
  ), 
  fnType = type function (x as list, y as list) as number
    meta [
      Documentation.Name = "Pearson", 
      Documentation.LongDescription = "This function calculates the Pearson correlation coefficient between two lists of numbers.", 
      Documentation.Examples = {
        [
          Description = "Calculate the Pearson correlation coefficient for two lists of numbers.",
          Code        = "=Pearson({1, 2, 3, 4}, {4, 5, 6, 7})", 
          Result      = "1"
        ]
      }
    ]
in
  Value.ReplaceType(Pearson, fnType)

      ],
      [
        Name = "QuartileStats", 
        Category = "Math", 
        Function = let 

  QuartileStats = 

  Function.From(type function(val as number, col as list) as record, (params) =>

let 
    l = List.Sort(params{1}),
    count = List.Count(l),
    q1 = count * 0.25,
    q2 = count * 0.5,
    q3 = count * 0.75,
    fnRunCheck = (check as number)=>
        let 
            get_q = if check = Number.IntegerDivide(check,1) then List.Average({l{Number.RoundAwayFromZero(check,0)-1}, l{Number.RoundAwayFromZero(check,0)}}) else l{Number.RoundAwayFromZero(check,0)}
        in   
            get_q,
    q1_val = fnRunCheck(q1),
    q2_val = fnRunCheck(q2),
    q3_val = fnRunCheck(q3),
    iqr =q3_val - q1_val,
    return =  [
        quartile = if params{0} <= q1_val then 1 else if params{0}  <= q2_val then 2 else if params{0}  <= q3_val then 3 else 4,
        q1= q1_val,
        q2 = q2_val,
        q3 = q3_val,
        interquartile_range = iqr,
        outlier = if params{0} < q1_val -  (1.5*iqr) then true else if params{0}  > q3_val + (1.5 * iqr) then true else false
        ]
in 
    return),
  fnType = type function (val as number, col as list) as record
    meta [
      Documentation.Name = "QuartileStats",
      Documentation.LongDescription = "This provides quartiles and whether a row value is an outlier based on a column of data/list."
    ]
in
  Value.ReplaceType(QuartileStats, fnType)
      ],
      [
        Name = "Z", 
        Category = "Math", 
        Function = let
  Z = Function.From(type function(test_type as text, value as number) as record, (params)=>
    let

      // define z table - taken from https://www.math.arizona.edu/~rsims/ma464/standardnormaltable.pdf
      standard = Table.FromRecords(
        {
          [z = - 3.99, area_left = 0.00003, area_right = 0.99997, position = "below mean"],
          [z = - 3.98, area_left = 0.00003, area_right = 0.99997, position = "below mean"],
          [z = - 3.97, area_left = 0.00004, area_right = 0.99996, position = "below mean"],
          [z = - 3.96, area_left = 0.00004, area_right = 0.99996, position = "below mean"],
          [z = - 3.95, area_left = 0.00004, area_right = 0.99996, position = "below mean"],
          [z = - 3.94, area_left = 0.00004, area_right = 0.99996, position = "below mean"],
          [z = - 3.93, area_left = 0.00004, area_right = 0.99996, position = "below mean"],
          [z = - 3.92, area_left = 0.00004, area_right = 0.99996, position = "below mean"],
          [z = - 3.91, area_left = 0.00005, area_right = 0.99995, position = "below mean"],
          [z = - 3.9, area_left = 0.00005, area_right = 0.99995, position = "below mean"],
          [z = - 3.89, area_left = 0.00005, area_right = 0.99995, position = "below mean"],
          [z = - 3.88, area_left = 0.00005, area_right = 0.99995, position = "below mean"],
          [z = - 3.87, area_left = 0.00005, area_right = 0.99995, position = "below mean"],
          [z = - 3.86, area_left = 0.00006, area_right = 0.99994, position = "below mean"],
          [z = - 3.85, area_left = 0.00006, area_right = 0.99994, position = "below mean"],
          [z = - 3.84, area_left = 0.00006, area_right = 0.99994, position = "below mean"],
          [z = - 3.83, area_left = 0.00006, area_right = 0.99994, position = "below mean"],
          [z = - 3.82, area_left = 0.00007, area_right = 0.99993, position = "below mean"],
          [z = - 3.81, area_left = 0.00007, area_right = 0.99993, position = "below mean"],
          [z = - 3.8, area_left = 0.00007, area_right = 0.99993, position = "below mean"],
          [z = - 3.79, area_left = 0.00008, area_right = 0.99992, position = "below mean"],
          [z = - 3.78, area_left = 0.00008, area_right = 0.99992, position = "below mean"],
          [z = - 3.77, area_left = 0.00008, area_right = 0.99992, position = "below mean"],
          [z = - 3.76, area_left = 0.00008, area_right = 0.99992, position = "below mean"],
          [z = - 3.75, area_left = 0.00009, area_right = 0.99991, position = "below mean"],
          [z = - 3.74, area_left = 0.00009, area_right = 0.99991, position = "below mean"],
          [z = - 3.73, area_left = 0.0001, area_right = 0.9999, position = "below mean"],
          [z = - 3.72, area_left = 0.0001, area_right = 0.9999, position = "below mean"],
          [z = - 3.71, area_left = 0.0001, area_right = 0.9999, position = "below mean"],
          [z = - 3.7, area_left = 0.00011, area_right = 0.99989, position = "below mean"],
          [z = - 3.69, area_left = 0.00011, area_right = 0.99989, position = "below mean"],
          [z = - 3.68, area_left = 0.00012, area_right = 0.99988, position = "below mean"],
          [z = - 3.67, area_left = 0.00012, area_right = 0.99988, position = "below mean"],
          [z = - 3.66, area_left = 0.00013, area_right = 0.99987, position = "below mean"],
          [z = - 3.65, area_left = 0.00013, area_right = 0.99987, position = "below mean"],
          [z = - 3.64, area_left = 0.00014, area_right = 0.99986, position = "below mean"],
          [z = - 3.63, area_left = 0.00014, area_right = 0.99986, position = "below mean"],
          [z = - 3.62, area_left = 0.00015, area_right = 0.99985, position = "below mean"],
          [z = - 3.61, area_left = 0.00015, area_right = 0.99985, position = "below mean"],
          [z = - 3.6, area_left = 0.00016, area_right = 0.99984, position = "below mean"],
          [z = - 3.59, area_left = 0.00017, area_right = 0.99983, position = "below mean"],
          [z = - 3.58, area_left = 0.00017, area_right = 0.99983, position = "below mean"],
          [z = - 3.57, area_left = 0.00018, area_right = 0.99982, position = "below mean"],
          [z = - 3.56, area_left = 0.00019, area_right = 0.99981, position = "below mean"],
          [z = - 3.55, area_left = 0.00019, area_right = 0.99981, position = "below mean"],
          [z = - 3.54, area_left = 0.0002, area_right = 0.9998, position = "below mean"],
          [z = - 3.53, area_left = 0.00021, area_right = 0.99979, position = "below mean"],
          [z = - 3.52, area_left = 0.00022, area_right = 0.99978, position = "below mean"],
          [z = - 3.51, area_left = 0.00022, area_right = 0.99978, position = "below mean"],
          [z = - 3.5, area_left = 0.00023, area_right = 0.99977, position = "below mean"],
          [z = - 3.49, area_left = 0.00024, area_right = 0.99976, position = "below mean"],
          [z = - 3.48, area_left = 0.00025, area_right = 0.99975, position = "below mean"],
          [z = - 3.47, area_left = 0.00026, area_right = 0.99974, position = "below mean"],
          [z = - 3.46, area_left = 0.00027, area_right = 0.99973, position = "below mean"],
          [z = - 3.45, area_left = 0.00028, area_right = 0.99972, position = "below mean"],
          [z = - 3.44, area_left = 0.00029, area_right = 0.99971, position = "below mean"],
          [z = - 3.43, area_left = 0.0003, area_right = 0.9997, position = "below mean"],
          [z = - 3.42, area_left = 0.00031, area_right = 0.99969, position = "below mean"],
          [z = - 3.41, area_left = 0.00032, area_right = 0.99968, position = "below mean"],
          [z= - 3.37, area_left = 0.00038, area_right = 0.99962, position = "below mean"],
          [z = - 3.36, area_left = 0.00039, area_right = 0.99961, position = "below mean"],
          [z = - 3.35, area_left = 0.0004, area_right = 0.9996, position = "below mean"],
          [z = - 3.34, area_left = 0.00042, area_right = 0.99958, position = "below mean"],
          [z = - 3.33, area_left = 0.00043, area_right = 0.99957, position = "below mean"],
          [z = - 3.32, area_left = 0.00045, area_right = 0.99955, position = "below mean"],
          [z = - 3.31, area_left = 0.00047, area_right = 0.99953, position = "below mean"],
          [z = - 3.3, area_left = 0.00048, area_right = 0.99952, position = "below mean"],
          [z = - 3.29, area_left = 0.0005, area_right = 0.9995, position = "below mean"],
          [z = - 3.28, area_left = 0.00052, area_right = 0.99948, position = "below mean"],
          [z = - 3.27, area_left = 0.00054, area_right = 0.99946, position = "below mean"],
          [z = - 3.26, area_left = 0.00056, area_right = 0.99944, position = "below mean"],
          [z = - 3.25, area_left = 0.00058, area_right = 0.99942, position = "below mean"],
          [z = - 3.24, area_left = 0.0006, area_right = 0.9994, position = "below mean"],
          [z = - 3.23, area_left = 0.00062, area_right = 0.99938, position = "below mean"],
          [z = - 3.22, area_left = 0.00064, area_right = 0.99936, position = "below mean"],
          [z = - 3.21, area_left = 0.00066, area_right = 0.99934, position = "below mean"],
          [z = - 3.2, area_left = 0.00069, area_right = 0.99931, position = "below mean"],
          [z = - 3.19, area_left = 0.00071, area_right = 0.99929, position = "below mean"],
          [z = - 3.18, area_left = 0.00074, area_right = 0.99926, position = "below mean"],
          [z = - 3.17, area_left = 0.00076, area_right = 0.99924, position = "below mean"],
          [z = - 3.16, area_left = 0.00079, area_right = 0.99921, position = "below mean"],
          [z = - 3.15, area_left = 0.00082, area_right = 0.99918, position = "below mean"],
          [z = - 3.14, area_left = 0.00084, area_right = 0.99916, position = "below mean"],
          [z = - 3.13, area_left = 0.00087, area_right = 0.99913, position = "below mean"],
          [z = - 3.12, area_left = 0.0009, area_right = 0.9991, position = "below mean"],
          [z = - 3.11, area_left = 0.00094, area_right = 0.99906, position = "below mean"],
          [z = - 3.1, area_left = 0.00097, area_right = 0.99903, position = "below mean"],
          [z = - 3.09, area_left = 0.001, area_right = 0.999, position = "below mean"],
          [z = - 3.08, area_left = 0.00104, area_right = 0.99896, position = "below mean"],
          [z = - 3.07, area_left = 0.00107, area_right = 0.99893, position = "below mean"],
          [z = - 3.06, area_left = 0.00111, area_right = 0.99889, position = "below mean"],
          [z = - 3.05, area_left = 0.00114, area_right = 0.99886, position = "below mean"],
          [z = - 3.04, area_left = 0.00118, area_right = 0.99882, position = "below mean"],
          [z = - 3.03, area_left = 0.00122, area_right = 0.99878, position = "below mean"],
          [z = - 3.02, area_left = 0.00126, area_right = 0.99874, position = "below mean"],
          [z = - 3.01, area_left = 0.00131, area_right = 0.99869, position = "below mean"],
          [z = - 3, area_left = 0.00135, area_right = 0.99865, position = "below mean"],
          [z = - 2.99, area_left = 0.00139, area_right = 0.99861, position = "below mean"],
          [z = - 2.98, area_left = 0.00144, area_right = 0.99856, position = "below mean"],
          [z = - 2.97, area_left = 0.00149, area_right = 0.99851, position = "below mean"],
          [z = - 2.96, area_left = 0.00154, area_right = 0.99846, position = "below mean"],
          [z = - 2.95, area_left = 0.00159, area_right = 0.99841, position = "below mean"],
          [z = - 2.94, area_left = 0.00164, area_right = 0.99836, position = "below mean"],
          [z = - 2.93, area_left = 0.00169, area_right = 0.99831, position = "below mean"],
          [z = - 2.92, area_left = 0.00175, area_right = 0.99825, position = "below mean"],
          [z = - 2.91, area_left = 0.00181, area_right = 0.99819, position = "below mean"],
          [z = - 2.9, area_left = 0.00187, area_right = 0.99813, position = "below mean"],
          [z = - 2.89, area_left = 0.00193, area_right = 0.99807, position = "below mean"],
          [z = - 2.88, area_left = 0.00199, area_right = 0.99801, position = "below mean"],
          [z = - 2.87, area_left = 0.00205, area_right = 0.99795, position = "below mean"],
          [z = - 2.86, area_left = 0.00212, area_right = 0.99788, position = "below mean"],
          [z = - 2.85, area_left = 0.00219, area_right = 0.99781, position = "below mean"],
          [z = - 2.84, area_left = 0.00226, area_right = 0.99774, position = "below mean"],
          [z = - 2.83, area_left = 0.00233, area_right = 0.99767, position = "below mean"],
          [z = - 2.82, area_left = 0.0024, area_right = 0.9976, position = "below mean"],
          [z = - 2.81, area_left = 0.00248, area_right = 0.99752, position = "below mean"],
          [z = - 2.8, area_left = 0.00256, area_right = 0.99744, position = "below mean"],
          [z = - 2.79, area_left = 0.00264, area_right = 0.99736, position = "below mean"],
          [z = - 2.78, area_left = 0.00272, area_right = 0.99728, position = "below mean"],
          [z = - 2.77, area_left = 0.0028, area_right = 0.9972, position = "below mean"],
          [z = - 2.76, area_left = 0.00289, area_right = 0.99711, position = "below mean"],
          [z = - 2.75, area_left = 0.00298, area_right = 0.99702, position = "below mean"],
          [z = - 2.74, area_left = 0.00307, area_right = 0.99693, position = "below mean"],
          [z = - 2.73, area_left = 0.00317, area_right = 0.99683, position = "below mean"],
          [z = - 2.72, area_left = 0.00326, area_right = 0.99674, position = "below mean"],
          [z = - 2.71, area_left = 0.00336, area_right = 0.99664, position = "below mean"],
          [z = - 2.7, area_left = 0.00347, area_right = 0.99653, position = "below mean"],
          [z = - 2.69, area_left = 0.00357, area_right = 0.99643, position = "below mean"],
          [z = - 2.68, area_left = 0.00368, area_right = 0.99632, position = "below mean"],
          [z = - 2.67, area_left = 0.00379, area_right = 0.99621, position = "below mean"],
          [z = - 2.66, area_left = 0.00391, area_right = 0.99609, position = "below mean"],
          [z = - 2.65, area_left = 0.00402, area_right = 0.99598, position = "below mean"],
          [z = - 2.64, area_left = 0.00415, area_right = 0.99585, position = "below mean"],
          [z = - 2.63, area_left = 0.00427, area_right = 0.99573, position = "below mean"],
          [z = - 2.62, area_left = 0.0044, area_right = 0.9956, position = "below mean"],
          [z = - 2.61, area_left = 0.00453, area_right = 0.99547, position = "below mean"],
          [z = - 2.6, area_left = 0.00466, area_right = 0.99534, position = "below mean"],
          [z = - 2.59, area_left = 0.0048, area_right = 0.9952, position = "below mean"],
          [z = - 2.58, area_left = 0.00494, area_right = 0.99506, position = "below mean"],
          [z = - 2.57, area_left = 0.00508, area_right = 0.99492, position = "below mean"],
          [z = - 2.56, area_left = 0.00523, area_right = 0.99477, position = "below mean"],
          [z = - 2.55, area_left = 0.00539, area_right = 0.99461, position = "below mean"],
          [z = - 2.54, area_left = 0.00554, area_right = 0.99446, position = "below mean"],
          [z = - 2.53, area_left = 0.0057, area_right = 0.9943, position = "below mean"],
          [z = - 2.52, area_left = 0.00587, area_right = 0.99413, position = "below mean"],
          [z = - 2.51, area_left = 0.00604, area_right = 0.99396, position = "below mean"],
          [z = - 2.5, area_left = 0.00621, area_right = 0.99379, position = "below mean"],
          [z = - 2.49, area_left = 0.00639, area_right = 0.99361, position = "below mean"],
          [z = - 2.48, area_left = 0.00657, area_right = 0.99343, position = "below mean"],
          [z = - 2.47, area_left = 0.00676, area_right = 0.99324, position = "below mean"],
          [z = - 2.46, area_left = 0.00695, area_right = 0.99305, position = "below mean"],
          [z = - 2.45, area_left = 0.00714, area_right = 0.99286, position = "below mean"],
          [z = - 2.44, area_left = 0.00734, area_right = 0.99266, position = "below mean"],
          [z = - 2.43, area_left = 0.00755, area_right = 0.99245, position = "below mean"],
          [z = - 2.42, area_left = 0.00776, area_right = 0.99224, position = "below mean"],
          [z = - 2.41, area_left = 0.00798, area_right = 0.99202, position = "below mean"],
          [z = - 2.4, area_left = 0.0082, area_right = 0.9918, position = "below mean"],
          [z = - 2.39, area_left = 0.00842, area_right = 0.99158, position = "below mean"],
          [z = - 2.38, area_left = 0.00866, area_right = 0.99134, position = "below mean"],
          [z = - 2.37, area_left = 0.00889, area_right = 0.99111, position = "below mean"],
          [z = - 2.36, area_left = 0.00914, area_right = 0.99086, position = "below mean"],
          [z = - 2.35, area_left = 0.00939, area_right = 0.99061, position = "below mean"],
          [z = - 2.34, area_left = 0.00964, area_right = 0.99036, position = "below mean"],
          [z = - 2.33, area_left = 0.0099, area_right = 0.9901, position = "below mean"],
          [z = - 2.32, area_left = 0.01017, area_right = 0.98983, position = "below mean"],
          [z = - 2.31, area_left = 0.01044, area_right = 0.98956, position = "below mean"],
          [z = - 2.3, area_left = 0.01072, area_right = 0.98928, position = "below mean"],
          [z = - 2.29, area_left = 0.01101, area_right = 0.98899, position = "below mean"],
          [z = - 2.28, area_left = 0.0113, area_right = 0.9887, position = "below mean"],
          [z = - 2.27, area_left = 0.0116, area_right = 0.9884, position = "below mean"],
          [z = - 2.26, area_left = 0.01191, area_right = 0.98809, position = "below mean"],
          [z = - 2.25, area_left = 0.01222, area_right = 0.98778, position = "below mean"],
          [z = - 2.24, area_left = 0.01255, area_right = 0.98745, position = "below mean"],
          [z = - 2.23, area_left = 0.01287, area_right = 0.98713, position = "below mean"],
          [z = - 2.22, area_left = 0.01321, area_right = 0.98679, position = "below mean"],
          [z = - 2.21, area_left = 0.01355, area_right = 0.98645, position = "below mean"],
          [z = - 2.2, area_left = 0.0139, area_right = 0.9861, position = "below mean"],
          [z = - 2.19, area_left = 0.01426, area_right = 0.98574, position = "below mean"],
          [z = - 2.18, area_left = 0.01463, area_right = 0.98537, position = "below mean"],
          [z = - 2.17, area_left = 0.015, area_right = 0.985, position = "below mean"],
          [z = - 2.16, area_left = 0.01539, area_right = 0.98461, position = "below mean"],
          [z = - 2.15, area_left = 0.01578, area_right = 0.98422, position = "below mean"],
          [z = - 2.14, area_left = 0.01618, area_right = 0.98382, position = "below mean"],
          [z = - 2.13, area_left = 0.01659, area_right = 0.98341, position = "below mean"],
          [z = - 2.12, area_left = 0.017, area_right = 0.983, position = "below mean"],
          [z = - 2.11, area_left = 0.01743, area_right = 0.98257, position = "below mean"],
          [z = - 2.1, area_left = 0.01786, area_right = 0.98214, position = "below mean"],
          [z = - 2.09, area_left = 0.01831, area_right = 0.98169, position = "below mean"],
          [z = - 2.08, area_left = 0.01876, area_right = 0.98124, position = "below mean"],
          [z = - 2.07, area_left = 0.01923, area_right = 0.98077, position = "below mean"],
          [z = - 2.06, area_left = 0.0197, area_right = 0.9803, position = "below mean"],
          [z = - 2.05, area_left = 0.02018, area_right = 0.97982, position = "below mean"],
          [z = - 2.04, area_left = 0.02068, area_right = 0.97932, position = "below mean"],
          [z = - 2.03, area_left = 0.02118, area_right = 0.97882, position = "below mean"],
          [z = - 2.02, area_left = 0.02169, area_right = 0.97831, position = "below mean"],
          [z = - 2.01, area_left = 0.02222, area_right = 0.97778, position = "below mean"],
          [z = - 2, area_left = 0.02275, area_right = 0.97725, position = "below mean"],
          [z = - 1.99, area_left = 0.0233, area_right = 0.9767, position = "below mean"],
          [z = - 1.98, area_left = 0.02385, area_right = 0.97615, position = "below mean"],
          [z = - 1.97, area_left = 0.02442, area_right = 0.97558, position = "below mean"],
          [z = - 1.96, area_left = 0.025, area_right = 0.975, position = "below mean"],
          [z = - 1.95, area_left = 0.02559, area_right = 0.97441, position = "below mean"],
          [z = - 1.94, area_left = 0.02619, area_right = 0.97381, position = "below mean"],
          [z = - 1.93, area_left = 0.0268, area_right = 0.9732, position = "below mean"],
          [z = - 1.92, area_left = 0.02743, area_right = 0.97257, position = "below mean"],
          [z = - 1.91, area_left = 0.02807, area_right = 0.97193, position = "below mean"],
          [z = - 1.9, area_left = 0.02872, area_right = 0.97128, position = "below mean"],
          [z = - 1.89, area_left = 0.02938, area_right = 0.97062, position = "below mean"],
          [z = - 1.88, area_left = 0.03005, area_right = 0.96995, position = "below mean"],
          [z = - 1.87, area_left = 0.03074, area_right = 0.96926, position = "below mean"],
          [z = - 1.86, area_left = 0.03144, area_right = 0.96856, position = "below mean"],
          [z = - 1.85, area_left = 0.03216, area_right = 0.96784, position = "below mean"],
          [z = - 1.84, area_left = 0.03288, area_right = 0.96712, position = "below mean"],
          [z = - 1.83, area_left = 0.03362, area_right = 0.96638, position = "below mean"],
          [z = - 1.82, area_left = 0.03438, area_right = 0.96562, position = "below mean"],
          [z = - 1.81, area_left = 0.03515, area_right = 0.96485, position = "below mean"],
          [z = - 1.8, area_left = 0.03593, area_right = 0.96407, position = "below mean"],
          [z = - 1.79, area_left = 0.03673, area_right = 0.96327, position = "below mean"],
          [z = - 1.78, area_left = 0.03754, area_right = 0.96246, position = "below mean"],
          [z = - 1.77, area_left = 0.03836, area_right = 0.96164, position = "below mean"],
          [z = - 1.76, area_left = 0.0392, area_right = 0.9608, position = "below mean"],
          [z = - 1.75, area_left = 0.04006, area_right = 0.95994, position = "below mean"],
          [z = - 1.74, area_left = 0.04093, area_right = 0.95907, position = "below mean"],
          [z = - 1.73, area_left = 0.04182, area_right = 0.95818, position = "below mean"],
          [z = - 1.72, area_left = 0.04272, area_right = 0.95728, position = "below mean"],
          [z = - 1.71, area_left = 0.04363, area_right = 0.95637, position = "below mean"],
          [z = - 1.7, area_left = 0.04457, area_right = 0.95543, position = "below mean"],
          [z = - 1.69, area_left = 0.04551, area_right = 0.95449, position = "below mean"],
          [z = - 1.68, area_left = 0.04648, area_right = 0.95352, position = "below mean"],
          [z = - 1.67, area_left = 0.04746, area_right = 0.95254, position = "below mean"],
          [z = - 1.66, area_left = 0.04846, area_right = 0.95154, position = "below mean"],
          [z = - 1.65, area_left = 0.04947, area_right = 0.95053, position = "below mean"],
          [z = - 1.64, area_left = 0.0505, area_right = 0.9495, position = "below mean"],
          [z = - 1.63, area_left = 0.05155, area_right = 0.94845, position = "below mean"],
          [z = - 1.62, area_left = 0.05262, area_right = 0.94738, position = "below mean"],
          [z = - 1.61, area_left = 0.0537, area_right = 0.9463, position = "below mean"],
          [z = - 1.6, area_left = 0.0548, area_right = 0.9452, position = "below mean"],
          [z = - 1.59, area_left = 0.05592, area_right = 0.94408, position = "below mean"],
          [z = - 1.58, area_left = 0.05705, area_right = 0.94295, position = "below mean"],
          [z = - 1.57, area_left = 0.05821, area_right = 0.94179, position = "below mean"],
          [z = - 1.56, area_left = 0.05938, area_right = 0.94062, position = "below mean"],
          [z = - 1.55, area_left = 0.06057, area_right = 0.93943, position = "below mean"],
          [z = - 1.54, area_left = 0.06178, area_right = 0.93822, position = "below mean"],
          [z = - 1.53, area_left = 0.06301, area_right = 0.93699, position = "below mean"],
          [z = - 1.52, area_left = 0.06426, area_right = 0.93574, position = "below mean"],
          [z = - 1.51, area_left = 0.06552, area_right = 0.93448, position = "below mean"],
          [z = - 1.5, area_left = 0.06681, area_right = 0.93319, position = "below mean"],
          [z = - 1.49, area_left = 0.06811, area_right = 0.93189, position = "below mean"],
          [z = - 1.48, area_left = 0.06944, area_right = 0.93056, position = "below mean"],
          [z = - 1.47, area_left = 0.07078, area_right = 0.92922, position = "below mean"],
          [z = - 1.46, area_left = 0.07215, area_right = 0.92785, position = "below mean"],
          [z = - 1.45, area_left = 0.07353, area_right = 0.92647, position = "below mean"],
          [z = - 1.44, area_left = 0.07493, area_right = 0.92507, position = "below mean"],
          [z = - 1.43, area_left = 0.07636, area_right = 0.92364, position = "below mean"],
          [z = - 1.42, area_left = 0.0778, area_right = 0.9222, position = "below mean"],
          [z = - 1.41, area_left = 0.07927, area_right = 0.92073, position = "below mean"],
          [z = - 1.4, area_left = 0.08076, area_right = 0.91924, position = "below mean"],
          [z = - 1.39, area_left = 0.08226, area_right = 0.91774, position = "below mean"],
          [z = - 1.38, area_left = 0.08379, area_right = 0.91621, position = "below mean"],
          [z = - 1.37, area_left = 0.08534, area_right = 0.91466, position = "below mean"],
          [z = - 1.36, area_left = 0.08691, area_right = 0.91309, position = "below mean"],
          [z = - 1.35, area_left = 0.08851, area_right = 0.91149, position = "below mean"],
          [z = - 1.34, area_left = 0.09012, area_right = 0.90988, position = "below mean"],
          [z = - 1.33, area_left = 0.09176, area_right = 0.90824, position = "below mean"],
          [z = - 1.32, area_left = 0.09342, area_right = 0.90658, position = "below mean"],
          [z = - 1.31, area_left = 0.0951, area_right = 0.9049, position = "below mean"],
          [z = - 1.3, area_left = 0.0968, area_right = 0.9032, position = "below mean"],
          [z = - 1.29, area_left = 0.09853, area_right = 0.90147, position = "below mean"],
          [z = - 1.28, area_left = 0.10027, area_right = 0.89973, position = "below mean"],
          [z = - 1.27, area_left = 0.10204, area_right = 0.89796, position = "below mean"],
          [z = - 1.26, area_left = 0.10383, area_right = 0.89617, position = "below mean"],
          [z = - 1.25, area_left = 0.10565, area_right = 0.89435, position = "below mean"],
          [z = - 1.24, area_left = 0.10749, area_right = 0.89251, position = "below mean"],
          [z = - 1.23, area_left = 0.10935, area_right = 0.89065, position = "below mean"],
          [z = - 1.22, area_left = 0.11123, area_right = 0.88877, position = "below mean"],
          [z = - 1.21, area_left = 0.11314, area_right = 0.88686, position = "below mean"],
          [z = - 1.2, area_left = 0.11507, area_right = 0.88493, position = "below mean"],
          [z = - 1.19, area_left = 0.11702, area_right = 0.88298, position = "below mean"],
          [z = - 1.18, area_left = 0.119, area_right = 0.881, position = "below mean"],
          [z = - 1.17, area_left = 0.121, area_right = 0.879, position = "below mean"],
          [z = - 1.16, area_left = 0.12302, area_right = 0.87698, position = "below mean"],
          [z = - 1.15, area_left = 0.12507, area_right = 0.87493, position = "below mean"],
          [z = - 1.14, area_left = 0.12714, area_right = 0.87286, position = "below mean"],
          [z = - 1.13, area_left = 0.12924, area_right = 0.87076, position = "below mean"],
          [z = - 1.12, area_left = 0.13136, area_right = 0.86864, position = "below mean"],
          [z = - 1.11, area_left = 0.1335, area_right = 0.8665, position = "below mean"],
          [z = - 1.1, area_left = 0.13567, area_right = 0.86433, position = "below mean"],
          [z = - 1.09, area_left = 0.13786, area_right = 0.86214, position = "below mean"],
          [z = - 1.08, area_left = 0.14007, area_right = 0.85993, position = "below mean"],
          [z = - 1.07, area_left = 0.14231, area_right = 0.85769, position = "below mean"],
          [z = - 1.06, area_left = 0.14457, area_right = 0.85543, position = "below mean"],
          [z = - 1.05, area_left = 0.14686, area_right = 0.85314, position = "below mean"],
          [z = - 1.04, area_left = 0.14917, area_right = 0.85083, position = "below mean"],
          [z = - 1.03, area_left = 0.15151, area_right = 0.84849, position = "below mean"],
          [z = - 1.02, area_left = 0.15386, area_right = 0.84614, position = "below mean"],
          [z = - 1.01, area_left = 0.15625, area_right = 0.84375, position = "below mean"],
          [z = - 1, area_left = 0.15866, area_right = 0.84134, position = "below mean"],
          [z = - 0.99, area_left = 0.16109, area_right = 0.83891, position = "below mean"],
          [z = - 0.98, area_left = 0.16354, area_right = 0.83646, position = "below mean"],
          [z = - 0.97, area_left = 0.16602, area_right = 0.83398, position = "below mean"],
          [z = - 0.96, area_left = 0.16853, area_right = 0.83147, position = "below mean"],
          [z = - 0.95, area_left = 0.17106, area_right = 0.82894, position = "below mean"],
          [z = - 0.94, area_left = 0.17361, area_right = 0.82639, position = "below mean"],
          [z = - 0.93, area_left = 0.17619, area_right = 0.82381, position = "below mean"],
          [z = - 0.92, area_left = 0.17879, area_right = 0.82121, position = "below mean"],
          [z = - 0.91, area_left = 0.18141, area_right = 0.81859, position = "below mean"],
          [z = - 0.9, area_left = 0.18406, area_right = 0.81594, position = "below mean"],
          [z = - 0.89, area_left = 0.18673, area_right = 0.81327, position = "below mean"],
          [z = - 0.88, area_left = 0.18943, area_right = 0.81057, position = "below mean"],
          [z = - 0.87, area_left = 0.19215, area_right = 0.80785, position = "below mean"],
          [z = - 0.86, area_left = 0.19489, area_right = 0.80511, position = "below mean"],
          [z = - 0.85, area_left = 0.19766, area_right = 0.80234, position = "below mean"],
          [z = - 0.84, area_left = 0.20045, area_right = 0.79955, position = "below mean"],
          [z = - 0.83, area_left = 0.20327, area_right = 0.79673, position = "below mean"],
          [z = - 0.82, area_left = 0.20611, area_right = 0.79389, position = "below mean"],
          [z = - 0.81, area_left = 0.20897, area_right = 0.79103, position = "below mean"],
          [z = - 0.8, area_left = 0.21186, area_right = 0.78814, position = "below mean"],
          [z = - 0.79, area_left = 0.21476, area_right = 0.78524, position = "below mean"],
          [z = - 0.78, area_left = 0.2177, area_right = 0.7823, position = "below mean"],
          [z = - 0.77, area_left = 0.22065, area_right = 0.77935, position = "below mean"],
          [z = - 0.76, area_left = 0.22363, area_right = 0.77637, position = "below mean"],
          [z = - 0.75, area_left = 0.22663, area_right = 0.77337, position = "below mean"],
          [z = - 0.74, area_left = 0.22965, area_right = 0.77035, position = "below mean"],
          [z = - 0.73, area_left = 0.2327, area_right = 0.7673, position = "below mean"],
          [z = - 0.72, area_left = 0.23576, area_right = 0.76424, position = "below mean"],
          [z = - 0.71, area_left = 0.23885, area_right = 0.76115, position = "below mean"],
          [z = - 0.7, area_left = 0.24196, area_right = 0.75804, position = "below mean"],
          [z = - 0.69, area_left = 0.2451, area_right = 0.7549, position = "below mean"],
          [z = - 0.68, area_left = 0.24825, area_right = 0.75175, position = "below mean"],
          [z = - 0.67, area_left = 0.25143, area_right = 0.74857, position = "below mean"],
          [z = - 0.66, area_left = 0.25463, area_right = 0.74537, position = "below mean"],
          [z = - 0.65, area_left = 0.25785, area_right = 0.74215, position = "below mean"],
          [z = - 0.64, area_left = 0.26109, area_right = 0.73891, position = "below mean"],
          [z = - 0.63, area_left = 0.26435, area_right = 0.73565, position = "below mean"],
          [z = - 0.62, area_left = 0.26763, area_right = 0.73237, position = "below mean"],
          [z = - 0.61, area_left = 0.27093, area_right = 0.72907, position = "below mean"],
          [z = - 0.6, area_left = 0.27425, area_right = 0.72575, position = "below mean"],
          [z = - 0.59, area_left = 0.2776, area_right = 0.7224, position = "below mean"],
          [z = - 0.58, area_left = 0.28096, area_right = 0.71904, position = "below mean"],
          [z = - 0.57, area_left = 0.28434, area_right = 0.71566, position = "below mean"],
          [z = - 0.56, area_left = 0.28774, area_right = 0.71226, position = "below mean"],
          [z = - 0.55, area_left = 0.29116, area_right = 0.70884, position = "below mean"],
          [z = - 0.54, area_left = 0.2946, area_right = 0.7054, position = "below mean"],
          [z = - 0.53, area_left = 0.29806, area_right = 0.70194, position = "below mean"],
          [z = - 0.52, area_left = 0.30153, area_right = 0.69847, position = "below mean"],
          [z = - 0.51, area_left = 0.30503, area_right = 0.69497, position = "below mean"],
          [z = - 0.5, area_left = 0.30854, area_right = 0.69146, position = "below mean"],
          [z = - 0.49, area_left = 0.31207, area_right = 0.68793, position = "below mean"],
          [z = - 0.48, area_left = 0.31561, area_right = 0.68439, position = "below mean"],
          [z = - 0.47, area_left = 0.31918, area_right = 0.68082, position = "below mean"],
          [z = - 0.46, area_left = 0.32276, area_right = 0.67724, position = "below mean"],
          [z = - 0.45, area_left = 0.32636, area_right = 0.67364, position = "below mean"],
          [z = - 0.44, area_left = 0.32997, area_right = 0.67003, position = "below mean"],
          [z = - 0.43, area_left = 0.3336, area_right = 0.6664, position = "below mean"],
          [z = - 0.42, area_left = 0.33724, area_right = 0.66276, position = "below mean"],
          [z = - 0.41, area_left = 0.3409, area_right = 0.6591, position = "below mean"],
          [z = - 0.4, area_left = 0.34458, area_right = 0.65542, position = "below mean"],
          [z = - 0.39, area_left = 0.34827, area_right = 0.65173, position = "below mean"],
          [z = - 0.38, area_left = 0.35197, area_right = 0.64803, position = "below mean"],
          [z = - 0.37, area_left = 0.35569, area_right = 0.64431, position = "below mean"],
          [z = - 0.36, area_left = 0.35942, area_right = 0.64058, position = "below mean"],
          [z = - 0.35, area_left = 0.36317, area_right = 0.63683, position = "below mean"],
          [z = - 0.34, area_left = 0.36693, area_right = 0.63307, position = "below mean"],
          [z = - 0.33, area_left = 0.3707, area_right = 0.6293, position = "below mean"],
          [z = - 0.32, area_left = 0.37448, area_right = 0.62552, position = "below mean"],
          [z = - 0.31, area_left = 0.37828, area_right = 0.62172, position = "below mean"],
          [z = - 0.3, area_left = 0.38209, area_right = 0.61791, position = "below mean"],
          [z = - 0.29, area_left = 0.38591, area_right = 0.61409, position = "below mean"],
          [z = - 0.28, area_left = 0.38974, area_right = 0.61026, position = "below mean"],
          [z = - 0.27, area_left = 0.39358, area_right = 0.60642, position = "below mean"],
          [z = - 0.26, area_left = 0.39743, area_right = 0.60257, position = "below mean"],
          [z = - 0.25, area_left = 0.40129, area_right = 0.59871, position = "below mean"],
          [z = - 0.24, area_left = 0.40517, area_right = 0.59483, position = "below mean"],
          [z = - 0.23, area_left = 0.40905, area_right = 0.59095, position = "below mean"],
          [z = - 0.22, area_left = 0.41294, area_right = 0.58706, position = "below mean"],
          [z = - 0.21, area_left = 0.41683, area_right = 0.58317, position = "below mean"],
          [z = - 0.2, area_left = 0.42074, area_right = 0.57926, position = "below mean"],
          [z = - 0.19, area_left = 0.42465, area_right = 0.57535, position = "below mean"],
          [z = - 0.18, area_left = 0.42858, area_right = 0.57142, position = "below mean"],
          [z = - 0.17, area_left = 0.43251, area_right = 0.56749, position = "below mean"],
          [z = - 0.16, area_left = 0.43644, area_right = 0.56356, position = "below mean"],
          [z = - 0.15, area_left = 0.44038, area_right = 0.55962, position = "below mean"],
          [z = - 0.14, area_left = 0.44433, area_right = 0.55567, position = "below mean"],
          [z = - 0.13, area_left = 0.44828, area_right = 0.55172, position = "below mean"],
          [z = - 0.12, area_left = 0.45224, area_right = 0.54776, position = "below mean"],
          [z = - 0.11, area_left = 0.4562, area_right = 0.5438, position = "below mean"],
          [z = - 0.1, area_left = 0.46017, area_right = 0.53983, position = "below mean"],
          [z = - 0.09, area_left = 0.46414, area_right = 0.53586, position = "at mean"],
          [z = - 0.08, area_left = 0.46812, area_right = 0.53188, position = "above mean"],
          [z = - 0.07, area_left = 0.4721, area_right = 0.5279, position = "above mean"],
          [z = - 0.06, area_left = 0.47608, area_right = 0.52392, position = "above mean"],
          [z = - 0.05, area_left = 0.48006, area_right = 0.51994, position = "above mean"],
          [z = - 0.04, area_left = 0.48405, area_right = 0.51595, position = "above mean"],
          [z = - 0.03, area_left = 0.48803, area_right = 0.51197, position = "above mean"],
          [z = - 0.02, area_left = 0.49202, area_right = 0.50798, position = "above mean"],
          [z = - 0.01, area_left = 0.49601, area_right = 0.50399, position = "above mean"],
          [z = 0, area_left = 0.5, area_right = 0.5, position = "above mean"],
          [z = 0, area_left = 0.5, area_right = 0.5, position = "above mean"],
          [z = 0.01, area_left = 0.50399, area_right = 0.49601, position = "above mean"],
          [z = 0.02, area_left = 0.50798, area_right = 0.49202, position = "above mean"],
          [z = 0.03, area_left = 0.51197, area_right = 0.48803, position = "above mean"],
          [z = 0.04, area_left = 0.51595, area_right = 0.48405, position = "above mean"],
          [z = 0.05, area_left = 0.51994, area_right = 0.48006, position = "above mean"],
          [z = 0.06, area_left = 0.52392, area_right = 0.47608, position = "above mean"],
          [z = 0.07, area_left = 0.5279, area_right = 0.4721, position = "above mean"],
          [z = 0.08, area_left = 0.53188, area_right = 0.46812, position = "above mean"],
          [z = 0.09, area_left = 0.53586, area_right = 0.46414, position = "above mean"],
          [z = 0.1, area_left = 0.53983, area_right = 0.46017, position = "above mean"],
          [z = 0.11, area_left = 0.5438, area_right = 0.4562, position = "above mean"],
          [z = 0.12, area_left = 0.54776, area_right = 0.45224, position = "above mean"],
          [z = 0.13, area_left = 0.55172, area_right = 0.44828, position = "above mean"],
          [z = 0.14, area_left = 0.55567, area_right = 0.44433, position = "above mean"],
          [z = 0.15, area_left = 0.55962, area_right = 0.44038, position = "above mean"],
          [z = 0.16, area_left = 0.56356, area_right = 0.43644, position = "above mean"],
          [z = 0.17, area_left = 0.56749, area_right = 0.43251, position = "above mean"],
          [z = 0.18, area_left = 0.57142, area_right = 0.42858, position = "above mean"],
          [z = 0.19, area_left = 0.57535, area_right = 0.42465, position = "above mean"],
          [z = 0.2, area_left = 0.57926, area_right = 0.42074, position = "above mean"],
          [z = 0.21, area_left = 0.58317, area_right = 0.41683, position = "above mean"],
          [z = 0.22, area_left = 0.58706, area_right = 0.41294, position = "above mean"],
          [z = 0.23, area_left = 0.59095, area_right = 0.40905, position = "above mean"],
          [z = 0.24, area_left = 0.59483, area_right = 0.40517, position = "above mean"],
          [z = 0.25, area_left = 0.59871, area_right = 0.40129, position = "above mean"],
          [z = 0.26, area_left = 0.60257, area_right = 0.39743, position = "above mean"],
          [z = 0.27, area_left = 0.60642, area_right = 0.39358, position = "above mean"],
          [z = 0.28, area_left = 0.61026, area_right = 0.38974, position = "above mean"],
          [z = 0.29, area_left = 0.61409, area_right = 0.38591, position = "above mean"],
          [z = 0.3, area_left = 0.61791, area_right = 0.38209, position = "above mean"],
          [z = 0.31, area_left = 0.62172, area_right = 0.37828, position = "above mean"],
          [z = 0.32, area_left = 0.62552, area_right = 0.37448, position = "above mean"],
          [z = 0.33, area_left = 0.6293, area_right = 0.3707, position = "above mean"],
          [z = 0.34, area_left = 0.63307, area_right = 0.36693, position = "above mean"],
          [z = 0.35, area_left = 0.63683, area_right = 0.36317, position = "above mean"],
          [z = 0.36, area_left = 0.64058, area_right = 0.35942, position = "above mean"],
          [z = 0.37, area_left = 0.64431, area_right = 0.35569, position = "above mean"],
          [z = 0.38, area_left = 0.64803, area_right = 0.35197, position = "above mean"],
          [z = 0.39, area_left = 0.65173, area_right = 0.34827, position = "above mean"],
          [z = 0.4, area_left = 0.65542, area_right = 0.34458, position = "above mean"],
          [z = 0.41, area_left = 0.6591, area_right = 0.3409, position = "above mean"],
          [z = 0.42, area_left = 0.66276, area_right = 0.33724, position = "above mean"],
          [z = 0.43, area_left = 0.6664, area_right = 0.3336, position = "above mean"],
          [z = 0.44, area_left = 0.67003, area_right = 0.32997, position = "above mean"],
          [z = 0.45, area_left = 0.67364, area_right = 0.32636, position = "above mean"],
          [z = 0.46, area_left = 0.67724, area_right = 0.32276, position = "above mean"],
          [z = 0.47, area_left = 0.68082, area_right = 0.31918, position = "above mean"],
          [z = 0.48, area_left = 0.68439, area_right = 0.31561, position = "above mean"],
          [z = 0.49, area_left = 0.68793, area_right = 0.31207, position = "above mean"],
          [z = 0.5, area_left = 0.69146, area_right = 0.30854, position = "above mean"],
          [z = 0.51, area_left = 0.69497, area_right = 0.30503, position = "above mean"],
          [z = 0.52, area_left = 0.69847, area_right = 0.30153, position = "above mean"],
          [z = 0.53, area_left = 0.70194, area_right = 0.29806, position = "above mean"],
          [z = 0.54, area_left = 0.7054, area_right = 0.2946, position = "above mean"],
          [z = 0.55, area_left = 0.70884, area_right = 0.29116, position = "above mean"],
          [z = 0.56, area_left = 0.71226, area_right = 0.28774, position = "above mean"],
          [z = 0.57, area_left = 0.71566, area_right = 0.28434, position = "above mean"],
          [z = 0.58, area_left = 0.71904, area_right = 0.28096, position = "above mean"],
          [z = 0.59, area_left = 0.7224, area_right = 0.2776, position = "above mean"],
          [z = 0.6, area_left = 0.72575, area_right = 0.27425, position = "above mean"],
          [z = 0.61, area_left = 0.72907, area_right = 0.27093, position = "above mean"],
          [z = 0.62, area_left = 0.73237, area_right = 0.26763, position = "above mean"],
          [z = 0.63, area_left = 0.73565, area_right = 0.26435, position = "above mean"],
          [z = 0.64, area_left = 0.73891, area_right = 0.26109, position = "above mean"],
          [z = 0.65, area_left = 0.74215, area_right = 0.25785, position = "above mean"],
          [z = 0.66, area_left = 0.74537, area_right = 0.25463, position = "above mean"],
          [z = 0.67, area_left = 0.74857, area_right = 0.25143, position = "above mean"],
          [z = 0.68, area_left = 0.75175, area_right = 0.24825, position = "above mean"],
          [z = 0.69, area_left = 0.7549, area_right = 0.2451, position = "above mean"],
          [z = 0.7, area_left = 0.75804, area_right = 0.24196, position = "above mean"],
          [z = 0.71, area_left = 0.76115, area_right = 0.23885, position = "above mean"],
          [z = 0.72, area_left = 0.76424, area_right = 0.23576, position = "above mean"],
          [z = 0.73, area_left = 0.7673, area_right = 0.2327, position = "above mean"],
          [z = 0.74, area_left = 0.77035, area_right = 0.22965, position = "above mean"],
          [z = 0.75, area_left = 0.77337, area_right = 0.22663, position = "above mean"],
          [z = 0.76, area_left = 0.77637, area_right = 0.22363, position = "above mean"],
          [z = 0.77, area_left = 0.77935, area_right = 0.22065, position = "above mean"],
          [z = 0.78, area_left = 0.7823, area_right = 0.2177, position = "above mean"],
          [z = 0.79, area_left = 0.78524, area_right = 0.21476, position = "above mean"],
          [z = 0.8, area_left = 0.78814, area_right = 0.21186, position = "above mean"],
          [z = 0.81, area_left = 0.79103, area_right = 0.20897, position = "above mean"],
          [z = 0.82, area_left = 0.79389, area_right = 0.20611, position = "above mean"],
          [z = 0.83, area_left = 0.79673, area_right = 0.20327, position = "above mean"],
          [z = 0.84, area_left = 0.79955, area_right = 0.20045, position = "above mean"],
          [z = 0.85, area_left = 0.80234, area_right = 0.19766, position = "above mean"],
          [z = 0.86, area_left = 0.80511, area_right = 0.19489, position = "above mean"],
          [z = 0.87, area_left = 0.80785, area_right = 0.19215, position = "above mean"],
          [z = 0.88, area_left = 0.81057, area_right = 0.18943, position = "above mean"],
          [z = 0.89, area_left = 0.81327, area_right = 0.18673, position = "above mean"],
          [z = 0.9, area_left = 0.81594, area_right = 0.18406, position = "above mean"],
          [z = 0.91, area_left = 0.81859, area_right = 0.18141, position = "above mean"],
          [z = 0.92, area_left = 0.82121, area_right = 0.17879, position = "above mean"],
          [z = 0.93, area_left = 0.82381, area_right = 0.17619, position = "above mean"],
          [z = 0.94, area_left = 0.82639, area_right = 0.17361, position = "above mean"],
          [z = 0.95, area_left = 0.82894, area_right = 0.17106, position = "above mean"],
          [z = 0.96, area_left = 0.83147, area_right = 0.16853, position = "above mean"],
          [z = 0.97, area_left = 0.83398, area_right = 0.16602, position = "above mean"],
          [z = 0.98, area_left = 0.83646, area_right = 0.16354, position = "above mean"],
          [z = 0.99, area_left = 0.83891, area_right = 0.16109, position = "above mean"],
          [z = 1, area_left = 0.84134, area_right = 0.15866, position = "above mean"],
          [z = 1.01, area_left = 0.84375, area_right = 0.15625, position = "above mean"],
          [z = 1.02, area_left = 0.84614, area_right = 0.15386, position = "above mean"],
          [z = 1.03, area_left = 0.84849, area_right = 0.15151, position = "above mean"],
          [z = 1.04, area_left = 0.85083, area_right = 0.14917, position = "above mean"],
          [z = 1.05, area_left = 0.85314, area_right = 0.14686, position = "above mean"],
          [z = 1.06, area_left = 0.85543, area_right = 0.14457, position = "above mean"],
          [z = 1.07, area_left = 0.85769, area_right = 0.14231, position = "above mean"],
          [z = 1.08, area_left = 0.85993, area_right = 0.14007, position = "above mean"],
          [z = 1.09, area_left = 0.86214, area_right = 0.13786, position = "above mean"],
          [z = 1.1, area_left = 0.86433, area_right = 0.13567, position = "above mean"],
          [z = 1.11, area_left = 0.8665, area_right = 0.1335, position = "above mean"],
          [z = 1.12, area_left = 0.86864, area_right = 0.13136, position = "above mean"],
          [z = 1.13, area_left = 0.87076, area_right = 0.12924, position = "above mean"],
          [z = 1.14, area_left = 0.87286, area_right = 0.12714, position = "above mean"],
          [z = 1.15, area_left = 0.87493, area_right = 0.12507, position = "above mean"],
          [z = 1.16, area_left = 0.87698, area_right = 0.12302, position = "above mean"],
          [z = 1.17, area_left = 0.879, area_right = 0.121, position = "above mean"],
          [z = 1.18, area_left = 0.881, area_right = 0.119, position = "above mean"],
          [z = 1.19, area_left = 0.88298, area_right = 0.11702, position = "above mean"],
          [z = 1.2, area_left = 0.88493, area_right = 0.11507, position = "above mean"],
          [z = 1.21, area_left = 0.88686, area_right = 0.11314, position = "above mean"],
          [z = 1.22, area_left = 0.88877, area_right = 0.11123, position = "above mean"],
          [z = 1.23, area_left = 0.89065, area_right = 0.10935, position = "above mean"],
          [z = 1.24, area_left = 0.89251, area_right = 0.10749, position = "above mean"],
          [z = 1.25, area_left = 0.89435, area_right = 0.10565, position = "above mean"],
          [z = 1.26, area_left = 0.89617, area_right = 0.10383, position = "above mean"],
          [z = 1.27, area_left = 0.89796, area_right = 0.10204, position = "above mean"],
          [z = 1.28, area_left = 0.89973, area_right = 0.10027, position = "above mean"],
          [z = 1.29, area_left = 0.90147, area_right = 0.09853, position = "above mean"],
          [z = 1.3, area_left = 0.9032, area_right = 0.0968, position = "above mean"],
          [z = 1.31, area_left = 0.9049, area_right = 0.0951, position = "above mean"],
          [z = 1.32, area_left = 0.90658, area_right = 0.0934199999999999, position = "above mean"],
          [z = 1.33, area_left = 0.90824, area_right = 0.09176, position = "above mean"],
          [z = 1.34, area_left = 0.90988, area_right = 0.09012, position = "above mean"],
          [z = 1.35, area_left = 0.91149, area_right = 0.08851, position = "above mean"],
          [z = 1.36, area_left = 0.91309, area_right = 0.08691, position = "above mean"],
          [z = 1.37, area_left = 0.91466, area_right = 0.08534, position = "above mean"],
          [z = 1.38, area_left = 0.91621, area_right = 0.08379, position = "above mean"],
          [z = 1.39, area_left = 0.91774, area_right = 0.08226, position = "above mean"],
          [z = 1.4, area_left = 0.91924, area_right = 0.0807600000000001, position = "above mean"],
          [z = 1.41, area_left = 0.92073, area_right = 0.07927, position = "above mean"],
          [z = 1.42, area_left = 0.9222, area_right = 0.0778, position = "above mean"],
          [z = 1.43, area_left = 0.92364, area_right = 0.07636, position = "above mean"],
          [z = 1.44, area_left = 0.92507, area_right = 0.0749300000000001, position = "above mean"],
          [z = 1.45, area_left = 0.92647, area_right = 0.07353, position = "above mean"],
          [z = 1.46, area_left = 0.92785, area_right = 0.07215, position = "above mean"],
          [z = 1.47, area_left = 0.92922, area_right = 0.07078, position = "above mean"],
          [z = 1.48, area_left = 0.93056, area_right = 0.0694399999999999, position = "above mean"],
          [z = 1.49, area_left = 0.93189, area_right = 0.06811, position = "above mean"],
          [z = 1.5, area_left = 0.93319, area_right = 0.06681, position = "above mean"],
          [z = 1.51, area_left = 0.93448, area_right = 0.06552, position = "above mean"],
          [z = 1.52, area_left = 0.93574, area_right = 0.06426, position = "above mean"],
          [z = 1.53, area_left = 0.93699, area_right = 0.06301, position = "above mean"],
          [z = 1.54, area_left = 0.93822, area_right = 0.0617799999999999, position = "above mean"],
          [z = 1.55, area_left = 0.93943, area_right = 0.06057, position = "above mean"],
          [z = 1.56, area_left = 0.94062, area_right = 0.05938, position = "above mean"],
          [z = 1.57, area_left = 0.94179, area_right = 0.05821, position = "above mean"],
          [z = 1.58, area_left = 0.94295, area_right = 0.05705, position = "above mean"],
          [z = 1.59, area_left = 0.94408, area_right = 0.05592, position = "above mean"],
          [z = 1.6, area_left = 0.9452, area_right = 0.0548, position = "above mean"],
          [z = 1.61, area_left = 0.9463, area_right = 0.0537, position = "above mean"],
          [z = 1.62, area_left = 0.94738, area_right = 0.05262, position = "above mean"],
          [z = 1.63, area_left = 0.94845, area_right = 0.05155, position = "above mean"],
          [z = 1.64, area_left = 0.9495, area_right = 0.0505, position = "above mean"],
          [z = 1.65, area_left = 0.95053, area_right = 0.04947, position = "above mean"],
          [z = 1.66, area_left = 0.95154, area_right = 0.0484599999999999, position = "above mean"],
          [z = 1.67, area_left = 0.95254, area_right = 0.0474599999999999, position = "above mean"],
          [z = 1.68, area_left = 0.95352, area_right = 0.04648, position = "above mean"],
          [z = 1.69, area_left = 0.95449, area_right = 0.0455100000000001, position = "above mean"],
          [z = 1.7, area_left = 0.95543, area_right = 0.04457, position = "above mean"],
          [z = 1.71, area_left = 0.95637, area_right = 0.0436299999999999, position = "above mean"],
          [z = 1.72, area_left = 0.95728, area_right = 0.04272, position = "above mean"],
          [z = 1.73, area_left = 0.95818, area_right = 0.04182, position = "above mean"],
          [z = 1.74, area_left = 0.95907, area_right = 0.04093, position = "above mean"],
          [z = 1.75, area_left = 0.95994, area_right = 0.04006, position = "above mean"],
          [z = 1.76, area_left = 0.9608, area_right = 0.0392, position = "above mean"],
          [z = 1.77, area_left = 0.96164, area_right = 0.0383599999999999, position = "above mean"],
          [z = 1.78, area_left = 0.96246, area_right = 0.03754, position = "above mean"],
          [z = 1.79, area_left = 0.96327, area_right = 0.03673, position = "above mean"],
          [z = 1.8, area_left = 0.96407, area_right = 0.03593, position = "above mean"],
          [z = 1.81, area_left = 0.96485, area_right = 0.03515, position = "above mean"],
          [z = 1.82, area_left = 0.96562, area_right = 0.03438, position = "above mean"],
          [z = 1.83, area_left = 0.96638, area_right = 0.03362, position = "above mean"],
          [z = 1.84, area_left = 0.96712, area_right = 0.03288, position = "above mean"],
          [z = 1.85, area_left = 0.96784, area_right = 0.03216, position = "above mean"],
          [z = 1.86, area_left = 0.96856, area_right = 0.03144, position = "above mean"],
          [z = 1.87, area_left = 0.96926, area_right = 0.03074, position = "above mean"],
          [z = 1.88, area_left = 0.96995, area_right = 0.03005, position = "above mean"],
          [z = 1.89, area_left = 0.97062, area_right = 0.02938, position = "above mean"],
          [z = 1.9, area_left = 0.97128, area_right = 0.02872, position = "above mean"],
          [z = 1.91, area_left = 0.97193, area_right = 0.02807, position = "above mean"],
          [z = 1.92, area_left = 0.97257, area_right = 0.02743, position = "above mean"],
          [z = 1.93, area_left = 0.9732, area_right = 0.0268, position = "above mean"],
          [z = 1.94, area_left = 0.97381, area_right = 0.02619, position = "above mean"],
          [z = 1.95, area_left = 0.97441, area_right = 0.02559, position = "above mean"],
          [z = 1.96, area_left = 0.975, area_right = 0.025, position = "above mean"],
          [z = 1.97, area_left = 0.97558, area_right = 0.02442, position = "above mean"],
          [z = 1.98, area_left = 0.97615, area_right = 0.02385, position = "above mean"],
          [z = 1.99, area_left = 0.9767, area_right = 0.0233, position = "above mean"],
          [z = 2, area_left = 0.97725, area_right = 0.02275, position = "above mean"],
          [z = 2.01, area_left = 0.97778, area_right = 0.02222, position = "above mean"],
          [z = 2.02, area_left = 0.97831, area_right = 0.02169, position = "above mean"],
          [z = 2.03, area_left = 0.97882, area_right = 0.02118, position = "above mean"],
          [z = 2.04, area_left = 0.97932, area_right = 0.02068, position = "above mean"],
          [z = 2.05, area_left = 0.97982, area_right = 0.02018, position = "above mean"],
          [z = 2.06, area_left = 0.9803, area_right = 0.0197000000000001, position = "above mean"],
          [z = 2.07, area_left = 0.98077, area_right = 0.01923, position = "above mean"],
          [z = 2.08, area_left = 0.98124, area_right = 0.01876, position = "above mean"],
          [z = 2.09, area_left = 0.98169, area_right = 0.01831, position = "above mean"],
          [z = 2.1, area_left = 0.98214, area_right = 0.01786, position = "above mean"],
          [z = 2.11, area_left = 0.98257, area_right = 0.0174299999999999, position = "above mean"],
          [z = 2.12, area_left = 0.983, area_right = 0.017, position = "above mean"],
          [z = 2.13, area_left = 0.98341, area_right = 0.01659, position = "above mean"],
          [z = 2.14, area_left = 0.98382, area_right = 0.01618, position = "above mean"],
          [z = 2.15, area_left = 0.98422, area_right = 0.01578, position = "above mean"],
          [z = 2.16, area_left = 0.98461, area_right = 0.01539, position = "above mean"],
          [z = 2.17, area_left = 0.985, area_right = 0.015, position = "above mean"],
          [z = 2.18, area_left = 0.98537, area_right = 0.01463, position = "above mean"],
          [z = 2.19, area_left = 0.98574, area_right = 0.0142600000000001, position = "above mean"],
          [z = 2.2, area_left = 0.9861, area_right = 0.0139, position = "above mean"],
          [z = 2.21, area_left = 0.98645, area_right = 0.01355, position = "above mean"],
          [z = 2.22, area_left = 0.98679, area_right = 0.0132100000000001, position = "above mean"],
          [z = 2.23, area_left = 0.98713, area_right = 0.01287, position = "above mean"],
          [z = 2.24, area_left = 0.98745, area_right = 0.01255, position = "above mean"],
          [z = 2.25, area_left = 0.98778, area_right = 0.01222, position = "above mean"],
          [z = 2.26, area_left = 0.98809, area_right = 0.01191, position = "above mean"],
          [z = 2.27, area_left = 0.9884, area_right = 0.0116000000000001, position = "above mean"],
          [z = 2.28, area_left = 0.9887, area_right = 0.0113, position = "above mean"],
          [z = 2.29, area_left = 0.98899, area_right = 0.01101, position = "above mean"],
          [z = 2.3, area_left = 0.98928, area_right = 0.01072, position = "above mean"],
          [z = 2.31, area_left = 0.98956, area_right = 0.01044, position = "above mean"],
          [z = 2.32, area_left = 0.98983, area_right = 0.01017, position = "above mean"],
          [z = 2.33, area_left = 0.9901, area_right = 0.00990000000000002, position = "above mean"],
          [z = 2.34, area_left = 0.99036, area_right = 0.00963999999999998, position = "above mean"],
          [z = 2.35, area_left = 0.99061, area_right = 0.00939000000000001, position = "above mean"],
          [z = 2.36, area_left = 0.99086, area_right = 0.00914000000000004, position = "above mean"],
          [z = 2.37, area_left = 0.99111, area_right = 0.00888999999999995, position = "above mean"],
          [z = 2.38, area_left = 0.99134, area_right = 0.00866, position = "above mean"],
          [z = 2.39, area_left = 0.99158, area_right = 0.00841999999999998, position = "above mean"],
          [z = 2.4, area_left = 0.9918, area_right = 0.00819999999999999, position = "above mean"],
          [z = 2.41, area_left = 0.99202, area_right = 0.00797999999999999, position = "above mean"],
          [z = 2.42, area_left = 0.99224, area_right = 0.00775999999999999, position = "above mean"],
          [z = 2.43, area_left = 0.99245, area_right = 0.00754999999999995, position = "above mean"],
          [z = 2.44, area_left = 0.99266, area_right = 0.00734000000000001, position = "above mean"],
          [z = 2.45, area_left = 0.99286, area_right = 0.00714000000000004, position = "above mean"],
          [z = 2.46, area_left = 0.99305, area_right = 0.00695000000000001, position = "above mean"],
          [z = 2.47, area_left = 0.99324, area_right = 0.00675999999999999, position = "above mean"],
          [z = 2.48, area_left = 0.99343, area_right = 0.00656999999999996, position = "above mean"],
          [z = 2.49, area_left = 0.99361, area_right = 0.00639000000000001, position = "above mean"],
          [z = 2.5, area_left = 0.99379, area_right = 0.00621000000000005, position = "above mean"],
          [z = 2.51, area_left = 0.99396, area_right = 0.00604000000000005, position = "above mean"],
          [z = 2.52, area_left = 0.99413, area_right = 0.00587000000000004, position = "above mean"],
          [z = 2.53, area_left = 0.9943, area_right = 0.00570000000000004, position = "above mean"],
          [z = 2.54, area_left = 0.99446, area_right = 0.00553999999999999, position = "above mean"],
          [z = 2.55, area_left = 0.99461, area_right = 0.00539000000000001, position = "above mean"],
          [z = 2.56, area_left = 0.99477, area_right = 0.00522999999999996, position = "above mean"],
          [z = 2.57, area_left = 0.99492, area_right = 0.00507999999999997, position = "above mean"],
          [z = 2.58, area_left = 0.99506, area_right = 0.00493999999999994, position = "above mean"],
          [z = 2.59, area_left = 0.9952, area_right = 0.00480000000000003, position = "above mean"],
          [z = 2.6, area_left = 0.99534, area_right = 0.00466, position = "above mean"],
          [z = 2.61, area_left = 0.99547, area_right = 0.00453000000000003, position = "above mean"],
          [z = 2.62, area_left = 0.9956, area_right = 0.00439999999999996, position = "above mean"],
          [z = 2.63, area_left = 0.99573, area_right = 0.00427, position = "above mean"],
          [z = 2.64, area_left = 0.99585, area_right = 0.00414999999999999, position = "above mean"],
          [z = 2.65, area_left = 0.99598, area_right = 0.00402000000000002, position = "above mean"],
          [z = 2.66, area_left = 0.99609, area_right = 0.00390999999999997, position = "above mean"],
          [z = 2.67, area_left = 0.99621, area_right = 0.00378999999999996, position = "above mean"],
          [z = 2.68, area_left = 0.99632, area_right = 0.00368000000000002, position = "above mean"],
          [z = 2.69, area_left = 0.99643, area_right = 0.00356999999999996, position = "above mean"],
          [z = 2.7, area_left = 0.99653, area_right = 0.00346999999999997, position = "above mean"],
          [z = 2.71, area_left = 0.99664, area_right = 0.00336000000000003, position = "above mean"],
          [z = 2.72, area_left = 0.99674, area_right = 0.00326000000000004, position = "above mean"],
          [z = 2.73, area_left = 0.99683, area_right = 0.00317000000000001, position = "above mean"],
          [z = 2.74, area_left = 0.99693, area_right = 0.00307000000000002, position = "above mean"],
          [z = 2.75, area_left = 0.99702, area_right = 0.00297999999999998, position = "above mean"],
          [z = 2.76, area_left = 0.99711, area_right = 0.00288999999999995, position = "above mean"],
          [z = 2.77, area_left = 0.9972, area_right = 0.00280000000000002, position = "above mean"],
          [z = 2.78, area_left = 0.99728, area_right = 0.00271999999999994, position = "above mean"],
          [z = 2.79, area_left = 0.99736, area_right = 0.00263999999999998, position = "above mean"],
          [z = 2.8, area_left = 0.99744, area_right = 0.00256000000000001, position = "above mean"],
          [z = 2.81, area_left = 0.99752, area_right = 0.00248000000000004, position = "above mean"],
          [z = 2.82, area_left = 0.9976, area_right = 0.00239999999999996, position = "above mean"],
          [z = 2.83, area_left = 0.99767, area_right = 0.00233000000000005, position = "above mean"],
          [z = 2.84, area_left = 0.99774, area_right = 0.00226000000000004, position = "above mean"],
          [z = 2.85, area_left = 0.99781, area_right = 0.00219000000000003, position = "above mean"],
          [z = 2.86, area_left = 0.99788, area_right = 0.00212000000000001, position = "above mean"],
          [z = 2.87, area_left = 0.99795, area_right = 0.00205, position = "above mean"],
          [z = 2.88, area_left = 0.99801, area_right = 0.00199000000000005, position = "above mean"],
          [z = 2.89, area_left = 0.99807, area_right = 0.00192999999999999, position = "above mean"],
          [z = 2.9, area_left = 0.99813, area_right = 0.00187000000000004, position = "above mean"],
          [z = 2.91, area_left = 0.99819, area_right = 0.00180999999999998, position = "above mean"],
          [z = 2.92, area_left = 0.99825, area_right = 0.00175000000000003, position = "above mean"],
          [z = 2.93, area_left = 0.99831, area_right = 0.00168999999999997, position = "above mean"],
          [z = 2.94, area_left = 0.99836, area_right = 0.00163999999999997, position = "above mean"],
          [z = 2.95, area_left = 0.99841, area_right = 0.00158999999999998, position = "above mean"],
          [z = 2.96, area_left = 0.99846, area_right = 0.00153999999999999, position = "above mean"],
          [z = 2.97, area_left = 0.99851, area_right = 0.00148999999999999, position = "above mean"],
          [z = 2.98, area_left = 0.99856, area_right = 0.00144, position = "above mean"],
          [z = 2.99, area_left = 0.99861, area_right = 0.00139, position = "above mean"],
          [z = 3, area_left = 0.99865, area_right = 0.00134999999999996, position = "above mean"],
          [z = 3.01, area_left = 0.99869, area_right = 0.00131000000000003, position = "above mean"],
          [z = 3.02, area_left = 0.99874, area_right = 0.00126000000000004, position = "above mean"],
          [z = 3.03, area_left = 0.99878, area_right = 0.00122, position = "above mean"],
          [z = 3.04, area_left = 0.99882, area_right = 0.00117999999999996, position = "above mean"],
          [z = 3.05, area_left = 0.99886, area_right = 0.00114000000000003, position = "above mean"],
          [z = 3.06, area_left = 0.99889, area_right = 0.00110999999999994, position = "above mean"],
          [z = 3.07, area_left = 0.99893, area_right = 0.00107000000000002, position = "above mean"],
          [z = 3.08, area_left = 0.99896, area_right = 0.00104000000000004, position = "above mean"],
          [z = 3.09, area_left = 0.999, area_right = 0.001, position = "above mean"],
          [z = 3.1, area_left = 0.99903, area_right = 0.000970000000000026, position = "above mean"],
          [z = 3.11, area_left = 0.99906, area_right = 0.000940000000000052, position = "above mean"],
          [z = 3.12, area_left = 0.9991, area_right = 0.000900000000000012, position = "above mean"],
          [z = 3.13, area_left = 0.99913, area_right = 0.000870000000000037, position = "above mean"],
          [z = 3.14, area_left = 0.99916, area_right = 0.000839999999999952, position = "above mean"],
          [z = 3.15, area_left = 0.99918, area_right = 0.000820000000000043, position = "above mean"],
          [z = 3.16, area_left = 0.99921, area_right = 0.000789999999999957, position = "above mean"],
          [z = 3.17, area_left = 0.99924, area_right = 0.000759999999999983, position = "above mean"],
          [z = 3.18, area_left = 0.99926, area_right = 0.000739999999999963, position = "above mean"],
          [z = 3.19, area_left = 0.99929, area_right = 0.000709999999999988, position = "above mean"],
          [z = 3.2, area_left = 0.99931, area_right = 0.000689999999999968, position = "above mean"],
          [z = 3.21, area_left = 0.99934, area_right = 0.000659999999999994, position = "above mean"],
          [z = 3.22, area_left = 0.99936, area_right = 0.000639999999999974, position = "above mean"],
          [z = 3.23, area_left = 0.99938, area_right = 0.000619999999999954, position = "above mean"],
          [z = 3.24, area_left = 0.9994, area_right = 0.000600000000000045, position = "above mean"],
          [z = 3.25, area_left = 0.99942, area_right = 0.000580000000000025, position = "above mean"],
          [z = 3.26, area_left = 0.99944, area_right = 0.000560000000000005, position = "above mean"],
          [z = 3.27, area_left = 0.99946, area_right = 0.000539999999999985, position = "above mean"],
          [z = 3.28, area_left = 0.99948, area_right = 0.000519999999999965, position = "above mean"],
          [z = 3.29, area_left = 0.9995, area_right = 0.000499999999999945, position = "above mean"],
          [z = 3.3, area_left = 0.99952, area_right = 0.000480000000000036, position = "above mean"],
          [z = 3.31, area_left = 0.99953, area_right = 0.00046999999999997, position = "above mean"],
          [z = 3.32, area_left = 0.99955, area_right = 0.00044999999999995, position = "above mean"],
          [z = 3.33, area_left = 0.99957, area_right = 0.000430000000000041, position = "above mean"],
          [z = 3.34, area_left = 0.99958, area_right = 0.000419999999999976, position = "above mean"],
          [z = 3.35, area_left = 0.9996, area_right = 0.000399999999999956, position = "above mean"],
          [z = 3.36, area_left = 0.99961, area_right = 0.000390000000000001, position = "above mean"],
          [z = 3.37, area_left = 0.99962, area_right = 0.000380000000000047, position = "above mean"],
          [z = 3.38, area_left = 0.99964, area_right = 0.000360000000000027, position = "above mean"],
          [z = 3.39, area_left = 0.99965, area_right = 0.000349999999999961, position = "above mean"],
          [z = 3.4, area_left = 0.99966, area_right = 0.000340000000000007, position = "above mean"],
          [z = 3.41, area_left = 0.99968, area_right = 0.000319999999999987, position = "above mean"],
          [z = 3.42, area_left = 0.99969, area_right = 0.000310000000000032, position = "above mean"],
          [z = 3.43, area_left = 0.9997, area_right = 0.000299999999999967, position = "above mean"],
          [z = 3.44, area_left = 0.99971, area_right = 0.000290000000000012, position = "above mean"],
          [z = 3.45, area_left = 0.99972, area_right = 0.000279999999999947, position = "above mean"],
          [z = 3.46, area_left = 0.99973, area_right = 0.000269999999999992, position = "above mean"],
          [z = 3.47, area_left = 0.99974, area_right = 0.000260000000000038, position = "above mean"],
          [z = 3.48, area_left = 0.99975, area_right = 0.000249999999999972, position = "above mean"],
          [z = 3.49, area_left = 0.99976, area_right = 0.000240000000000018, position = "above mean"],
          [z = 3.5, area_left = 0.99977, area_right = 0.000229999999999952, position = "above mean"],
          [z = 3.51, area_left = 0.99978, area_right = 0.000219999999999998, position = "above mean"],
          [z = 3.52, area_left = 0.99978, area_right = 0.000219999999999998, position = "above mean"],
          [z = 3.53, area_left = 0.99979, area_right = 0.000210000000000043, position = "above mean"],
          [z = 3.54, area_left = 0.9998, area_right = 0.000199999999999978, position = "above mean"],
          [z = 3.55, area_left = 0.99981, area_right = 0.000190000000000023, position = "above mean"],
          [z = 3.56, area_left = 0.99981, area_right = 0.000190000000000023, position = "above mean"],
          [z = 3.57, area_left = 0.99982, area_right = 0.000179999999999958, position = "above mean"],
          [z = 3.58, area_left = 0.99983, area_right = 0.000170000000000003, position = "above mean"],
          [z = 3.59, area_left = 0.99983, area_right = 0.000170000000000003, position = "above mean"],
          [z = 3.6, area_left = 0.99984, area_right = 0.000160000000000049, position = "above mean"],
          [z = 3.61, area_left = 0.99985, area_right = 0.000149999999999983, position = "above mean"],
          [z = 3.62, area_left = 0.99985, area_right = 0.000149999999999983, position = "above mean"],
          [z = 3.63, area_left = 0.99986, area_right = 0.000140000000000029, position = "above mean"],
          [z = 3.64, area_left = 0.99986, area_right = 0.000140000000000029, position = "above mean"],
          [z = 3.65, area_left = 0.99987, area_right = 0.000129999999999963, position = "above mean"],
          [z = 3.66, area_left = 0.99987, area_right = 0.000129999999999963, position = "above mean"],
          [z = 3.67, area_left = 0.99988, area_right = 0.000120000000000009, position = "above mean"],
          [z = 3.68, area_left = 0.99988, area_right = 0.000120000000000009, position = "above mean"],
          [z = 3.69, area_left = 0.99989, area_right = 0.000110000000000054, position = "above mean"],
          [z = 3.7, area_left = 0.99989, area_right = 0.000110000000000054, position = "above mean"],
          [z = 3.71, area_left = 0.9999, area_right = 0.000099999999999989, position = "above mean"],
          [z = 3.72, area_left = 0.9999, area_right = 0.000099999999999989, position = "above mean"],
          [z = 3.73, area_left = 0.9999, area_right = 0.000099999999999989, position = "above mean"],
          [z = 3.74, area_left = 0.99991, area_right = 9.00000000000345E-05, position = "above mean"],
          [z = 3.75, area_left = 0.99991, area_right = 9.00000000000345E-05, position = "above mean"],
          [z = 3.76, area_left = 0.99992, area_right = 0.000079999999999969, position = "above mean"],
          [z = 3.77, area_left = 0.99992, area_right = 0.000079999999999969, position = "above mean"],
          [z = 3.78, area_left = 0.99992, area_right = 0.000079999999999969, position = "above mean"],
          [z = 3.79, area_left = 0.99992, area_right = 0.000079999999999969, position = "above mean"],
          [z = 3.8, area_left = 0.99993, area_right = 7.00000000000145E-05, position = "above mean"],
          [z = 3.81, area_left = 0.99993, area_right = 7.00000000000145E-05, position = "above mean"],
          [z = 3.82, area_left = 0.99993, area_right = 7.00000000000145E-05, position = "above mean"],
          [z = 3.83, area_left = 0.99994, area_right = 0.000059999999999949, position = "above mean"],
          [z = 3.84, area_left = 0.99994, area_right = 0.000059999999999949, position = "above mean"],
          [z = 3.85, area_left = 0.99994, area_right = 0.000059999999999949, position = "above mean"],
          [z = 3.86, area_left = 0.99994, area_right = 0.000059999999999949, position = "above mean"],
          [z = 3.87, area_left = 0.99995, area_right = 4.99999999999945E-05, position = "above mean"],
          [z = 3.88, area_left = 0.99995, area_right = 4.99999999999945E-05, position = "above mean"],
          [z = 3.89, area_left = 0.99995, area_right = 4.99999999999945E-05, position = "above mean"],
          [z = 3.9, area_left = 0.99995, area_right = 4.99999999999945E-05, position = "above mean"],
          [z = 3.91, area_left = 0.99995, area_right = 4.99999999999945E-05, position = "above mean"],
          [z = 3.92, area_left = 0.99996, area_right = 0.00004000000000004, position = "above mean"],
          [z = 3.93, area_left = 0.99996, area_right = 0.00004000000000004, position = "above mean"],
          [z = 3.94, area_left = 0.99996, area_right = 0.00004000000000004, position = "above mean"],
          [z = 3.95, area_left = 0.99996, area_right = 0.00004000000000004, position = "above mean"],
          [z = 3.96, area_left = 0.99996, area_right = 0.00004000000000004, position = "above mean"],
          [z = 3.97, area_left = 0.99996, area_right = 0.00004000000000004, position = "above mean"],
          [z = 3.98, area_left = 0.99997, area_right = 2.99999999999745E-05, position = "above mean"],
          [z = 3.99, area_left = 0.99997, area_right = 2.99999999999745E-05, position = "above mean"]
        },
        type table [z = number, area_left = number, area_right = number, position = text]
      ),

      // check the test type, if it is not z, subtract from 1
      v = if params{0} <> "z" then Number.RoundAwayFromZero(1 - params{1}, 3) else params{1},
      get_values =
        // lookup values based on test - default to z lookup
        if params{0} = "r" then
          Table.ToRecords(Table.LastN(Table.SelectRows(standard, each Number.RoundAwayFromZero([area_right], 3) = v), 1))
        else if params{0} = "l" then
          Table.ToRecords(Table.FirstN(Table.SelectRows(standard, each Number.RoundAwayFromZero([area_left], 3) = v), 1))
        else if params{0} = "t" then
          Table.SelectRows(standard, each Number.RoundAwayFromZero([area_left], 3) = Number.RoundAwayFromZero(v / 2, 3) or Number.RoundAwayFromZero([area_right], 3) = Number.RoundAwayFromZero(v / 2, 3))
        else
          Table.SelectRows(standard, each [z] = v)
    in
      get_values),
  fnType = type function (test_type as text, value as number) as record
    meta [
      Documentation.Name = "Z",
      Documentation.LongDescription = "This provides lookup capabilities on the Standard Table for Z Scores. " & "The second value is either the confidence level you are looking for or the z-score you are looking up.",
      Documentation.Examples = {
        [Description = "The test types can be the following: " & "t = two-tailed test; " & "l = left-tailed test; " & "r = right-tailed test; " & "z = lookup based on z score", Code = "Z(""r"", 0.95)", Result = "[z=1.64, area_left = 0.9495, area_right=0.0505, position= above mean]"]
      }
    ]
in
  Value.ReplaceType(Z, fnType)
      ],
      
      [
        Name = "RunSQLQuery", 
        Category = "SQL", 
        Function = let
  RunSQLQuery = Function.From(
    type function (Source as any, Query as text) as table, 
    (params) =>
      let
        // Connection information
        Source = params{0},
        
        // SQL Query string
        Query = params{1},
        
        // Run the SQL query with native query options
        Run = Value.NativeQuery(Source, Query, null,   
          // Enable query folding and preserve data types
          [EnableFolding = true, PreserveTypes = true]
        )
      in
        Run
  ), 
  fnType = type function (Source as any, Query as text) as table
    meta [
      Documentation.Name = "RunSQLQuery", 
      Documentation.LongDescription = "This function runs a SQL query against a specified data source. It takes the connection information and SQL query string as inputs and returns the result as a table. The function enables query folding and preserves data types.",
      Documentation.Examples = {
        [
          Description = "Run a SQL query against a data source.",
          Code        = "=RunSQLQuery(#Connection information, ""SELECT * FROM TableName"")", 
          Result      = "Table with query results"
        ]
      }
    ]
in
  Value.ReplaceType(RunSQLQuery, fnType)
      ],
      [
        Name = "EncodeText", 
        Category = "String", 
        Function = let
  EncodeText = 
    Function.From(
      type function (str as text) as text, 
      (params) =>
        let
          // Convert each character to its ASCII number and format as a 3-digit string
          return = Text.Combine(List.Transform(Text.ToList(params{0}), each Number.ToText(Character.ToNumber(_), "000")), "")
        in
          return
    ), 
  fnType = type function (str as text) as text
    meta [
      Documentation.Name = "EncodeText",
      Documentation.LongDescription = "This function takes a text string and encodes it by converting each character to its ASCII number, formatted as a 3-digit string.",
      Documentation.Examples = {
        [
          Description = "Encode the text 'Hello'.",
          Code        = "=EncodeText(""Hello"")", 
          Result      = "072101108108111"
        ]
      }
    ]
in
  Value.ReplaceType(EncodeText, fnType)

      ],
      [
        Name = "ReadFileToText", 
        Category = "String", 
        Function = let
  ReadFileToText = Function.From(
    type function (filepath as text) as text, 
    (params) =>
      let
        // Read the file contents as a table with one column
        file = Table.FromColumns({Lines.FromBinary(File.Contents(params{0}), null, null, 1252)}),
        
        // Combine all lines into a single text string, separated by line feeds
        return = Text.Combine(file[Column1], "#(lf)")
      in
        return
  ), 
  fnType = type function (filepath as text) as text
    meta [
      Documentation.Name = "ReadFileToText",
      Documentation.LongDescription = "This function reads the contents of a file and combines all lines into a single text string, separated by line feeds. It takes the file path as input and returns the combined text.",
      Documentation.Examples = {
        [
          Description = "Read the contents of a text file and combine all lines.",
          Code        = "=ReadFileToText(""C:\\path\\to\\file.txt"")", 
          Result      = "Combined text of the file"
        ]
      }
    ]
in
  Value.ReplaceType(ReadFileToText, fnType)

      ],
      [
        Name = "RemoveHTMLTags", 
        Category = "String", 
        Function = let
  RemoveHtmlTags = Function.From(
    type function (STRING as text) as text, 
    (params) =>
      let
        // Ensure the input string is not empty or null
        Source = if params{0} = "" or params{0} = null then "" else Text.From(params{0}),

        // Remove HTML tags and extract text
        RemoveTags = Html.Table(Source, {{"text", ":root"}}),

        // Get the text content from the first row
        GetText = RemoveTags{0}
      in
        GetText
  ), 
  fnType = type function (STRING as text) as text
    meta [
      Documentation.Name = "RemoveHtmlTags",
      Documentation.LongDescription = "This function removes HTML tags from a given text string and extracts the plain text content. It takes an HTML string as input and returns the text content.",
      Documentation.Examples = {
        [
          Description = "Remove HTML tags from a string.",
          Code        = "=RemoveHtmlTags(""<p>Hello, <b>world</b>!</p>"")", 
          Result      = "Hello, world!"
        ]
      }
    ]
in
  Value.ReplaceType(RemoveHtmlTags, fnType)
      ],
      [
        Name = "RemoveUnwantedCharacters", 
        Category = "String", 
        Function = let
  RemoveUnwantedCharacters = Function.From(
    type function (str as text, optional keep_upper as logical, optional keep_lower as logical, optional keep_nums as logical, optional keep_specials as logical, optional keep_chars as text) as text, 
    (params) =>
      let
        // Function to remove characters from the string
        fnRemove =
         (string as text, l as list) => 
            Text.Combine(
                List.Select(
                Text.ToList(string), 
                each List.Contains(l, Character.ToNumber(_)) = false
              ), 
              ""
            ),
        
        // Convert characters to keep into a list of their ASCII values
        chars_to_keep = if Text.Length(params{5}) > 0 then List.Transform(Text.ToList(params{5}), each Character.ToNumber(_)) else {},
        
        // ASCII values for uppercase letters
        upper = {65..90},
        
        // ASCII values for lowercase letters
        lower = {97..122},
        
        // Combine uppercase and lowercase letters
        alphas = List.Combine({upper, lower}),
        
        // ASCII values for numbers
        nums = {48..57},
        
        // ASCII values for special characters
        specials = List.RemoveItems({0..255}, List.Combine({alphas, nums})),
        
        // Determine if uppercase letters should be removed
        u = if params{1} = true then {} else upper,
        
        // Determine if lowercase letters should be removed
        l = if params{2} = true then {} else lower,
        
        // Determine if numbers should be removed
        n = if params{3} = true then {} else nums,
        
        // Determine if special characters should be removed
        s = if params{4} = true then {} else specials,  
        
        // Create a list of characters to remove, excluding those to keep
        remove_list = List.Distinct(List.RemoveItems(List.Combine({u, l, n, s}), chars_to_keep)), 
        
        // Apply the removal function
        return = fnRemove(params{0}, remove_list) 
      in
        return
  ), 
  fnType = type function (str as text, optional keep_upper as logical, optional keep_lower as logical, optional keep_nums as logical, optional keep_specials as logical, optional keep_chars as text) as text
    meta [
      Documentation.Name = "RemoveUnwantedCharacters", 
      Documentation.LongDescription = "This function removes unwanted characters from a text string based on specified options. It can keep or remove uppercase letters, lowercase letters, numbers, special characters, and additional specified characters.",
      Documentation.Examples = {
        [
          Description = "Remove all characters except lowercase letters and numbers.",
          Code        = "=RemoveUnwantedCharacters(""H3ll0! Th!s 1s @ t3st."", false, true, true, false, T"")", 
          Result      = "3ll0Ths1st3st"
        ]
      }
    ]
in
  Value.ReplaceType(RemoveUnwantedCharacters, fnType)
      ],
      [
        Name = "ColumnToList", 
        Category = "Tbl", 
        Function = let
  Source = Function.From(
    type function (t as table, column_name as text) as list, 
    (params) =>
      let
        // Convert the specified column to a list
        ColumnToList = Table.ToList(
                          Table.TransformColumnTypes(
                            Table.SelectColumns(
                              params{0}, 
                              {params{1}}
                            ),
                            {params{1}, 
                            type text}
                          )
                        )
      in
        ColumnToList
  ), 
  fnType = type function (t as table, column_name as text) as list
    meta [
      Documentation.Name = "ColumnToList", 
      Documentation.LongDescription = "This function converts a specified column from a given table into a list. It takes a table and a column name as input and returns the column as a list.",
      Documentation.Examples = {
        [
          Description = "Convert the 'A' column of a table to a list.",
          Code        = "=ColumnToList(#table({""A"", ""B""}, {{1, 2}, {3, 4}}), ""A"")", 
          Result      = "{1, 3}"
        ]
      }
    ]
in
  Value.ReplaceType(Source, fnType)
      ],
      [
        Name = "ConvertDateTimeZoneToDate", 
        Category = "Tbl", 
        Function = let
  ConvertDateTimeZoneToDate = Function.From(
    type function (tbl as table) as table, 
    (params) =>
      let
        // Select columns by data type "datetimezone" and get their names
        Select = Table.SelectRows(Table.Schema(params{0}), each _[Kind] = "datetimezone" or  _[Kind] = "datetime")[Name],
        
        // Get a count of the selected columns
        Count = List.Count(Select),
        
        // Use TransformColumnTypes and List.Zip to change the data types to "date"
        Result = Table.TransformColumnTypes(params{0}, List.Zip({Select, List.Repeat({type date}, Count)}))
      in
        Result
  ), 
  fnType = type function (tbl as table) as table
    meta [
      Documentation.Name = "ConvertDateTimeZoneToDate", 
      Documentation.LongDescription = "This function converts columns of type 'datetimezone' to type 'date' in a given table. It takes a table as input and returns the table with the specified columns' data types changed.",
      Documentation.Examples = {
        [
          Description = "Convert 'datetimezone' or 'datetime' columns to 'date' in a table.",
          Code        = "=ConvertDateTimeZoneToDate(#table({""DateTimeZoneColumn""}, {{#datetimezone(2023, 1, 1, 0, 0, 0, 0, 0)}}))", 
          Result      = "#table({""DateTimeZoneColumn""}, {{#date(2023, 1, 1)}})"
        ]
      }
    ]
in
  Value.ReplaceType(ConvertDateTimeZoneToDate, fnType)
      ],
      [
        Name = "fnRandomNumber", 
        Category = "Tbl", 
        Function = let
    fnRandomNumber =
    Function.From(type function(t as table, seed as number) as table, (params) =>
        let
            // Step 1: Add an index column to the input table to preserve row order and enable alignment
            Source = Table.AddIndexColumn(params{0}, "__Index", 0, 1, Int64.Type),

            // Step 2: Generate a reproducible list of random numbers using the provided seed
            // This ensures consistent output across refreshes or deployments
            Random_List = List.Random(Table.RowCount(params{0}), params{1}),

            // Step 3: Convert the random list into a table and add an index column for joining
            Add_Index_To_Random_List = Table.AddIndexColumn(
                Table.FromList(
                    Random_List,
                    Splitter.SplitByNothing(),
                    type table [Random = Number.Type],
                    null,
                    ExtraValues.Error
                ),
                "__Index",
                0,
                1
            ),

            // Step 4: Join the original table with the random number table using the index
            // This aligns each original row with its corresponding random value
            Join_Tables = Table.Join(
                Source,
                "__Index",
                Add_Index_To_Random_List,
                "__Index",
                JoinKind.Inner
            ),

            // Step 5: Remove the temporary index column to clean up the final output
            Remove_Index = Table.RemoveColumns(Join_Tables, "__Index")
        in
            Remove_Index
    ),

fnType = type function (t as table, seed as number) as table meta
[
    Documentation.Name = "fnRandomNumber",
    Documentation.LongDescription = "This function generates a reproducible list of random numbers for each row in the input table, using the provided seed for consistency. The random numbers are aligned with the original rows.",
    Documentation.Examples = {
        [
            Description = "Generate random numbers for a table with a seed value.",
            Code = "fnRandomNumber(MyTable, 12345)",
            Result = "A table with an additional column of random numbers."
        ]
    }
]
in
Value.ReplaceType(fnRandomNumber, fnType)
      ],
      [
        Name = "RemoveNullColumns", 
        Category = "Tbl", 
        Function = let
  RemoveNullColumns = Function.From(
    type function (tbl as table) as table, 
    (params) =>
      let
        // Select columns that are not completely null
        Source = 
          Table.SelectColumns(
            params{0}, 
            // Select all non-null column names
            Table.SelectRows(
              // Add a helper column for filtering null columns
              Table.AddColumn(
                Table.Profile(params{0}), 
                "IsNull", 
                each if [Count] = Number.From([NullCount]) then 1 else 0, 
                type number
              ), 
              each _[IsNull] = 0
            )[Column]
          )
      in
        Source
  ), 
  fnType = type function (tbl as table) as table
    meta [
      Documentation.Name = "RemoveNullColumns", 
      Documentation.LongDescription = "This function removes columns that are completely null from a given table. It takes a table as input and returns the table with only the columns that contain non-null values.",
      Documentation.Examples = {
        [
          Description = "Remove columns that are completely null from a table.",
          Code        = "=RemoveNullColumns(#table({""A"", ""B""}, {{1, null}, {2, null}}))", 
          Result      = "#table({""A""}, {{1}, {2}})"
        ]
      }
    ]
in
  Value.ReplaceType(RemoveNullColumns, fnType)

      ],
      [
        Name = "ReplaceInColumnNames", 
        Category = "Tbl", 
        Function = let
  Source = Function.From(
    type function (t as table, string as text, replacement as text) as table, 
    (params) =>
      let
        // Replace in one step -  based on Alex Powers's solution in his Github repo
        Replace = Table.TransformColumnNames(
                    params{0}, 
                    each Text.Proper(
                      Replacer.ReplaceText(_,
                        params{1}, 
                        params{2}
                    )
                )
            )
      in
        Replace
  ), 
  fnType = type function (t as table, string as text, replacement as text) as table
    meta [
      Documentation.Name = "ReplaceInColumnNames", 
      Documentation.LongDescription = "This function replaces underscores with spaces in the column names of a given table. It takes a table, a string to find, and a replacement string as input and returns the table with updated column names.",
      Documentation.Examples = {
        [
          Description = "Replace underscores with spaces in column names of a table.",
          Code        = "=ReplaceInColumnNames(#table({""A_B"", ""C_D""}, {{1, 2}, {3, 4}}), ""_"", "" "")", 
          Result      = "#table({""A B"", ""C D""}, {{1, 2}, {3, 4}})"
        ]
      }
    ]
in
  Value.ReplaceType(Source, fnType)
      ],
      [
        Name = "RoundColumns", 
        Category = "Tbl", 
        Function = let
  RoundColumns = Function.From(
    type function (t as table, decimal_places as number, optional exclusions as list) as table, 
    (params) =>
      let
        // Select columns that are of type Number
        Columns = Table.SelectRows(Table.Schema(params{0}), each _[TypeName] = "Number.Type")[Name],
        // Exclude any columns that do not need to be rounded
        Exclude = try List.RemoveItems(Columns, params{2}) otherwise Columns,
        // Create a list of transformation functions for rounding numbers
        Zip = List.Zip({Exclude, List.Repeat({(num) as number => Number.RoundAwayFromZero(num, params{1})}, List.Count(Exclude))}),
        // Apply the rounding transformation to the columns
        Txform = Table.TransformColumns(params{0}, Zip)
      in
        Txform
  ), 
  fnType = type function (t as table, decimal_places as number, optional exclusions as list) as table
    meta [
      Documentation.Name = "RoundColumns", 
      Documentation.LongDescription = "This function rounds the values in all numeric columns of a given table to a specified number of decimal places. It takes a table, the number of decimal places, and an optional list of columns to exclude as input and returns the table with rounded values.",
      Documentation.Examples = {
        [
          Description = "Round the values in numeric columns of a table to 2 decimal places.",
          Code        = "=RoundColumns(Table.TransformColumnTypes(#table({""A"", ""B""}, {{1.234, 2.345}, {3.456, 4.567}}),{{""A"", type number}, {""B"", type number}}), 2)", 
          Result      = "#table({""A"", ""B""}, {{1.23, 2.35}, {3.46, 4.57}})"
        ],
        [
          Description = "Round the values in numeric columns of a table to 2 decimal places, excluding the 'B' column.",
          Code        = "=RoundColumns(Table.TransformColumnTypes(#table({""A"", ""B""}, {{1.234, 2.345}, {3.456, 4.567}}),{{""A"", type number}, {""B"", type number}}), 2, {""B""})", 
          Result      = "#table({""A"", ""B""}, {{1.23, 2.345}, {3.46, 4.567}})"
        ]
      }
    ]
in
  Value.ReplaceType(RoundColumns, fnType)
      ],
      [
        Name = "CreateBatches", 
        Category = "Utils", 
        Function = let
  Source = Function.From(
    type function (batch as number, total as number, base as number) as table, 
    (params) =>
      let
        // Generate batches based on the input parameters
        batches = List.Generate(
          () => [
            from = params{2},
            to = params{0}
          ],
          each [to] <= params{1},
          each [
            from = [from] + params{0},
            to = if params{2} = 1 then [to] + params{0} else ([from] + (params{0}) * 2) - 1
          ]
        ),
        
        // Convert the list of batches to a table
        to_table = Table.FromList(batches, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        
        // Expand the record column to separate columns
        expanded = Table.ExpandRecordColumn(to_table, "Column1", {"from", "to"}, {"from", "to"}),
        
        // Change the column types to Int64
        changed_type = Table.TransformColumnTypes(expanded, {{"from", Int64.Type}, {"to", Int64.Type}}),
        
        // Add an index column to the table
        index = Table.AddIndexColumn(changed_type, "run", 1, 1, Int64.Type),
        
        // Reorder the columns for better readability
        reorder = Table.ReorderColumns(index, {"run", "from", "to"})
      in
        reorder
  ), 
  fnType = type function (batch as number, total as number, base as number) as table
    meta [
      Documentation.Name = "GenerateBatches", 
      Documentation.LongDescription = "This function generates batches based on the input parameters: batch size, total size, and base value. It returns a table with the batch ranges and an index column.", 
      Documentation.Examples = {
        [
          Description = "Generate batches with a batch size of 10, total size of 100, and base value of 1.",
          Code        = "=GenerateBatches(10, 100, 1)", 
          Result      = "#table({""run"", ""from"", ""to""}, {{1, 1, 10}, {2, 11, 20}, {3, 21, 30}, {4, 31, 40}, {5, 41, 50}, {6, 51, 60}, {7, 61, 70}, {8, 71, 80}, {9, 81, 90}, {10, 91, 100}})"
        ]
      }
    ]
in
  Value.ReplaceType(Source, fnType)

      ],
      [
        Name = "fnDynamicSelectList", 
        Category = "Utils", 
        Function = let
    fnDynamicSelectList =
    Function.From(type function(l as list, selections as list) as list, (params) =>
        let
            // Use List.Accumulate to process each selection criteria
            Source = 
            List.Accumulate(
                params{1}, // The selections list (criteria for what to select)
                {}, // Initial accumulator state (empty list)
                (state,current)=> 
                // Check if current selection contains a colon (indicating a range)
                if 
                    Text.Contains(current,":") 
                then 
                    // Handle range selection (e.g., "B:D" selects from B to D)
                    List.Combine({state,
                    List.Range(
                        params{0}, // The source list to select from
                        // Find starting position of the range
                        List.PositionOf(params{0},
                            Text.Split(
                                current
                                ,":"
                            ){0} // First part before colon (start of range)
                        ),                
                        // Calculate the count of items in the range
                        List.PositionOf(params{0},
                            Text.Split(
                                current
                                ,":"
                            ){1} // Second part after colon (end of range)
                        ) - List.PositionOf(params{0},
                            Text.Split(
                                current
                                ,":"
                            ){0} // Start position
                        )+1 // Add 1 to include the end item
                    )}) 
                else 
                    // Handle single item selection
                    List.Combine({state,{List.Select(params{0}, each _ = current){0}}})
            )
        in
            Source
    ),

fnType = type function (l as list, selections as list) as list meta
[
    Documentation.Name = "fnDynamicSelectList",
    Documentation.LongDescription = "This function dynamically selects items from a list based on selection criteria. It supports both individual item selection and range selection using colon notation (e.g., 'start:end'). The function accumulates selections and returns a combined list of selected items.",
    Documentation.Examples = {
        [
            Description = "Select specific items and ranges from a list.",
            Code = "fnDynamicSelectList({""A"", ""B"", ""C"", ""D"", ""E""}, {""A"", ""C:E""})",
            Result = "A list containing {""A"", ""C"", ""D"", ""E""}"
        ]
    }
]
in
Value.ReplaceType(fnDynamicSelectList, fnType)
      ],
      [
        Name = "GetFunctionMetadata", 
        Category = "Utils", 
        Function = let
  // Define the function using Function.From
  GetFunctionMetadata = Function.From(
    type function (function_name as text, return as text) as text,
    (params) =>
      let
        // Retrieve metadata for the given function name
        metadata = Value.Metadata(
          Value.Type(
            Table.SelectRows(Record.ToTable(#shared), each _[Name] = params{0})[Value]{0}
          )
        ),
        // Determine the result based on the 'return' parameter
        result = 
          if Text.Lower(params{1}) = "name" then
            metadata[Documentation.Name]
          else if Text.Lower(params{1}) = "description" then
            metadata[Documentation.Description]
          else if Text.Lower(params{1}) = "example" then
            metadata[Documentation.Examples]{0}
          else
            "Invalid return parameter value provided"
      in
        result
  ),

  // Define the function type with metadata
  fnType = type function (function_name as text, return as text) as text
    meta [
      Documentation.Name = "GetFunctionMetadata",
      Documentation.LongDescription = "This function takes a function name and return type (name, description, or example) and provides the metadata associated with the function.",
      Documentation.Examples = {
        [
          Description = "Get the name of a function.",
          Code        = "=GetFunctionMetadata(""Table.SelectRows"", ""name"")",
          Result      = "Table.SelectRows"
        ],
        [
          Description = "Get the description of a function.",
          Code        = "=GetFunctionMetadata(""Table.SelectRows"", ""description"")",
          Result      = "Returns a table that contains only the rows that match a condition."
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetFunctionMetadata, fnType)
      ],
      [
        Name = "PostRequest", 
        Category = "Utils", 
        Function = let
  // Define the function using Function.From
  PostRequest = Function.From(
    type function (SvcUrl as text, Content as text) as text,
    (SvcUrl, Content) =>
      let
        Response = Web.Contents(
          SvcUrl,
          [
            Content = Text.ToBinary(Content),
            // This can be edited for different header parameters
            Headers = [#"Content-Type" = "application/json"]
          ]
        ),
        Json = Json.Document(Response)
      in
        Json
  ),

  // Define the function type with metadata
  fnType = type function (SvcUrl as text, Content as text) as text
    meta [
      Documentation.Name = "PostRequest",
      Documentation.LongDescription = "This function makes a POST request to a specified URL with the provided content.",
      Documentation.Examples = {
        [
          Description = "Make a POST request to a sample API.",
          Code = "=PostRequest(""https://jsonplaceholder.typicode.com/posts"", ""{\""title\"": \""foo\"", \""body\"": \""bar\"", \""userId\"": 1}"")",
          Result = "{""title"":""foo"",""body"":""bar"",""userId"":1,""id"":101}"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(PostRequest, fnType)
      ],
      [
        Name = "Switch", 
        Category = "Utils", 
        Function = let
  Switch = Function.From(
    type function (value as any, l as list, default as any) as any, 
    (params) =>
      let
        // Function to select nth item of list
        // If you pass in zero, you get even indices
        // If you pass in one, you get odd indices
        fnSelectEvenOdd = (lst as list, remainder as number) as list =>
            let 
                result = List.Select(lst, each Number.Mod(List.PositionOf(lst, _), 2) = remainder)
            in    
                result,
        
        // After getting even and odd in separate lists, zip them together
        // This sets up a {function, return} item
        Zipped = List.Zip({fnSelectEvenOdd(params{1}, 0), fnSelectEvenOdd(params{1}, 1)}),

        // Now check each function and return the result that maps along with it
        Return = try List.Select(List.Transform(Zipped, each if _{0}(params{0}) = true then _{1} else null), each _ <> null){0} otherwise params{2}
      in
       Return
  ), 
  fnType = type function (value as any, l as list, default as any) as any
    meta [
      Documentation.Name = "Switch", 
      Documentation.LongDescription = "This function evaluates a value against a list of functions and returns the corresponding result. It takes a value, a list of functions and results, and a default value. If the value matches a function, the corresponding result is returned; otherwise, the default value is returned.",
      Documentation.Examples = {
        [
          Description = "Evaluate a value against a list of functions and return the corresponding result.",
          Code        = "=Switch(5, {each _ < 10, ""Less than 10"", each _ >= 10, ""10 or more""}, ""No match"")", 
          Result      = """Less than 10"""
        ],
        [
          Description = "Evaluate a value against a list of functions and return the default value if no match is found.",
          Code        = "=Switch(15, {each _ < 10, ""Less than 10"", each _ >= 10, ""10 or more""}, ""No match"")", 
          Result      = """10 or more"""
        ]
      }
    ]
in
  Value.ReplaceType(Switch, fnType)
      ],
      [
        Name = "CheckColorBlind", 
        Category = "UX", 
        Function = let 
// Source for matrices of values: https://www.inf.ufrgs.br/~oliveira/pubs_files/CVD_Simulation/CVD_Simulation.html
    CheckColorBlind = 

// Calculate RGB based on hex value
Function.From( type function(HEX as text) as table, (params) =>
  let
    // Split strings into list by each character, convert to upper, remove hash
    Source = if params{0} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{0}), "#")) else "#000000", 
    // Split the Source by each character
    SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source), 
    GetColor = (hexlist) =>
      let
        // Build the RGB list
        RGB = List.Combine({{"0" .. "9"}, {"A" .. "F"}}), 
        // Sub function to figure out RGB value
        GetRGB = (cval1, cval2) =>
          let
            RGBVal = (Number.From(cval1) * 16) + Number.From(cval2)
          in
            RGBVal, 
        // Get positions of each digit
        r = GetRGB(List.PositionOf(RGB, hexlist{0}), List.PositionOf(RGB, hexlist{1})), 
        g = GetRGB(List.PositionOf(RGB, hexlist{2}), List.PositionOf(RGB, hexlist{3})), 
        b = GetRGB(List.PositionOf(RGB, hexlist{4}), List.PositionOf(RGB, hexlist{5})), 
        // Combine R,G,B hex values to one hex value
        FinalRGB = Text.Combine({Text.From(r), Text.From(g), Text.From(b)}, ",")
      in
        FinalRGB, 
    CheckColorBlind = (red as number, green as number, blue as number) =>
      let
        tbl = Table.FromRecords(
          {
            [
              Severity = 0.0, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 1.0, g = 0.0, b = 0.0], 
                  [r = 0.0, g = 1.0, b = 0.0], 
                  [r = 0.0, g = 0.0, b = 1.0]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 1.0, g = 0.0, b = 0.0], 
                  [r = 0.0, g = 1.0, b = 0.0], 
                  [r = 0.0, g = 0.0, b = 1.0]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.0, g = 0.0, b = 0.0], 
                  [r = 0.0, g = 1.0, b = 0.0], 
                  [r = 0.0, g = 0.0, b = 1.0]
                }
              )
            ], 
            [
              Severity = 0.1, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.856167, g = 0.182038, b = - 0.038205], 
                  [r = 0.029342, g = 0.955115, b = 0.015544], 
                  [r = - 0.002880, g = - 0.001563, b = 1.004443]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.866435, g = 0.177704, b = - 0.044139], 
                  [r = 0.049567, g = 0.939063, b = 0.011370], 
                  [r = - 0.003453, g = 0.007233, b = 0.996220]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 0.926670, g = 0.092514, b = - 0.019184], 
                  [r = 0.021191, g = 0.964503, b = 0.014306], 
                  [r = 0.008437, g = 0.054813, b = 0.936750]
                }
              )
            ], 
            [
              Severity = 0.2, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.734766, g = 0.334872, b = - 0.069637], 
                  [r = 0.051840, g = 0.919198, b = 0.028963], 
                  [r = - 0.004928, g = - 0.004209, b = 1.009137]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.760729, g = 0.319078, b = - 0.079807], 
                  [r = 0.090568, g = 0.889315, b = 0.020117], 
                  [r = - 0.006027, g = 0.013325, b = 0.992702]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 0.895720, g = 0.133330, b = - 0.029050], 
                  [r = 0.029997, g = 0.945400, b = 0.024603], 
                  [r = 0.013027, g = 0.104707, b = 0.882266]
                }
              )
            ], 
            [
              Severity = 0.3, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.630323, g = 0.465641, b = - 0.095964], 
                  [r = 0.069181, g = 0.890046, b = 0.040773], 
                  [r = - 0.006308, g = - 0.007724, b = 1.014032]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.675425, g = 0.433850, b = - 0.109275], 
                  [r = 0.125303, g = 0.847755, b = 0.026942], 
                  [r = - 0.007950, g = 0.018572, b = 0.989378]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 0.905871, g = 0.127791, b = - 0.033662], 
                  [r = 0.026856, g = 0.941251, b = 0.031893], 
                  [r = 0.013410, g = 0.148296, b = 0.838294]
                }
              )
            ], 
            [
              Severity = 0.4, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.539009, g = 0.579343, b = - 0.118352], 
                  [r = 0.082546, g = 0.866121, b = 0.051332], 
                  [r = - 0.007136, g = - 0.011959, b = 1.019095]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.605511, g = 0.528560, b = - 0.134071], 
                  [r = 0.155318, g = 0.812366, b = 0.032316], 
                  [r = - 0.009376, g = 0.023176, b = 0.986200]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 0.948035, g = 0.089490, b = - 0.037526], 
                  [r = 0.014364, g = 0.946792, b = 0.038844], 
                  [r = 0.010853, g = 0.193991, b = 0.795156]
                }
              )
            ], 
            [
              Severity = 0.5, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.458064, g = 0.679578, b = - 0.137642], 
                  [r = 0.092785, g = 0.846313, b = 0.060902], 
                  [r = - 0.007494, g = - 0.016807, b = 1.024301]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.547494, g = 0.607765, b = - 0.155259], 
                  [r = 0.181692, g = 0.781742, b = 0.036566], 
                  [r = - 0.010410, g = 0.027275, b = 0.983136]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.017277, g = 0.027029, b = - 0.044306], 
                  [r = - 0.006113, g = 0.958479, b = 0.047634], 
                  [r = 0.006379, g = 0.248708, b = 0.744913]
                }
              )
            ], 
            [
              Severity = 0.6, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.385450, g = 0.769005, b = - 0.154455], 
                  [r = 0.100526, g = 0.829802, b = 0.069673], 
                  [r = - 0.007442, g = - 0.022190, b = 1.029632]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.498864, g = 0.674741, b = - 0.173604], 
                  [r = 0.205199, g = 0.754872, b = 0.039929], 
                  [r = - 0.011131, g = 0.030969, b = 0.980162]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.104996, g = - 0.046633, b = - 0.058363], 
                  [r = - 0.032137, g = 0.971635, b = 0.060503], 
                  [r = 0.001336, g = 0.317922, b = 0.680742]
                }
              )
            ], 
            [
              Severity = 0.7, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.319627, g = 0.849633, b = - 0.169261], 
                  [r = 0.106241, g = 0.815969, b = 0.077790], 
                  [r = - 0.007025, g = - 0.028051, b = 1.035076]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.457771, g = 0.731899, b = - 0.189670], 
                  [r = 0.226409, g = 0.731012, b = 0.042579], 
                  [r = - 0.011595, g = 0.034333, b = 0.977261]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.193214, g = - 0.109812, b = - 0.083402], 
                  [r = - 0.058496, g = 0.979410, b = 0.079086], 
                  [r = - 0.002346, g = 0.403492, b = 0.598854]
                }
              )
            ], 
            [
              Severity = 0.8, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.259411, g = 0.923008, b = - 0.182420], 
                  [r = 0.110296, g = 0.804340, b = 0.085364], 
                  [r = - 0.006276, g = - 0.034346, b = 1.040622]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.422823, g = 0.781057, b = - 0.203881], 
                  [r = 0.245752, g = 0.709602, b = 0.044646], 
                  [r = - 0.011843, g = 0.037423, b = 0.974421]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.257728, g = - 0.139648, b = - 0.118081], 
                  [r = - 0.078003, g = 0.975409, b = 0.102594], 
                  [r = - 0.003316, g = 0.501214, b = 0.502102]
                }
              )
            ], 
            [
              Severity = 0.9, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.203876, g = 0.990338, b = - 0.194214], 
                  [r = 0.112975, g = 0.794542, b = 0.092483], 
                  [r = - 0.005222, g = - 0.041043, b = 1.046265]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.392952, g = 0.823610, b = - 0.216562], 
                  [r = 0.263559, g = 0.690210, b = 0.046232], 
                  [r = - 0.011910, g = 0.040281, b = 0.971630]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.278864, g = - 0.125333, b = - 0.153531], 
                  [r = - 0.084748, g = 0.957674, b = 0.127074], 
                  [r = - 0.000989, g = 0.601151, b = 0.399838]
                }
              )
            ], 
            [
              Severity = 1.0, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.152286, g = 1.052583, b = - 0.204868], 
                  [r = 0.114503, g = 0.786281, b = 0.099216], 
                  [r = - 0.003882, g = - 0.048116, b = 1.051998]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.367322, g = 0.860646, b = - 0.227968], 
                  [r = 0.280085, g = 0.672501, b = 0.047413], 
                  [r = - 0.011820, g = 0.042940, b = 0.968881]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.255528, g = - 0.076749, b = - 0.178779], 
                  [r = - 0.078411, g = 0.930809, b = 0.147602], 
                  [r = 0.004733, g = 0.691367, b = 0.303900]
                }
              )
            ]
          }
        ), 
        Pro = Table.AddColumn(
          tbl, 
          "P", 
          each 
            let
              r = List.Min(
                {
                  red
                    * [Protanomaly][r]{0} + green
                    * [Protanomaly][g]{0} + blue
                    * [Protanomaly][b]{0}, 
                  255
                }
              ), 
              g = List.Min(
                {
                  red
                    * [Protanomaly][r]{1} + green
                    * [Protanomaly][g]{1} + blue
                    * [Protanomaly][b]{1}, 
                  255
                }
              ), 
              b = List.Min(
                {
                  red
                    * [Protanomaly][r]{2} + green
                    * [Protanomaly][g]{2} + blue
                    * [Protanomaly][b]{2}, 
                  255
                }
              )
            in
              Text.Combine(
                {
                  Text.From(Number.RoundAwayFromZero(Number.Abs(r), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(g), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(b), 0))
                }, 
                ","
              )
        ), 
        Deu = Table.AddColumn(
          Pro, 
          "D", 
          each 
            let
              r = List.Min(
                {
                  red
                    * [Deuteranomaly][r]{0} + green
                    * [Deuteranomaly][g]{0} + blue
                    * [Deuteranomaly][b]{0}, 
                  255
                }
              ), 
              g = List.Min(
                {
                  red
                    * [Deuteranomaly][r]{1} + green
                    * [Deuteranomaly][g]{1} + blue
                    * [Deuteranomaly][b]{1}, 
                  255
                }
              ), 
              b = List.Min(
                {
                  red
                    * [Deuteranomaly][r]{2} + green
                    * [Deuteranomaly][g]{2} + blue
                    * [Deuteranomaly][b]{2}, 
                  255
                }
              )
            in
              Text.Combine(
                {
                  Text.From(Number.RoundAwayFromZero(Number.Abs(r), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(g), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(b), 0))
                }, 
                ","
              )
        ), 
        Tri = Table.AddColumn(
          Deu, 
          "T", 
          each 
            let
              r = List.Min(
                {
                  red
                    * [Tritanomaly][r]{0} + green
                    * [Tritanomaly][g]{0} + blue
                    * [Tritanomaly][b]{0}, 
                  255
                }
              ), 
              g = List.Min(
                {
                  red
                    * [Tritanomaly][r]{1} + green
                    * [Tritanomaly][g]{1} + blue
                    * [Tritanomaly][b]{1}, 
                  255
                }
              ), 
              b = List.Min(
                {
                  red
                    * [Tritanomaly][r]{2} + green
                    * [Tritanomaly][g]{2} + blue
                    * [Tritanomaly][b]{2}, 
                  255
                }
              )
            in
              Text.Combine(
                {
                  Text.From(Number.RoundAwayFromZero(Number.Abs(r), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(g), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(b), 0))
                }, 
                ","
              )
        ), 
        ColorBlind = Table.SelectColumns(Tri, {"Severity", "P", "D", "T"})
      in
        ColorBlind, 
    GetHex = (red as number, green as number, blue as number) =>
      let
        // Build the RGB list
        RGB = List.Combine({{"0" .. "9"}, {"A" .. "F"}}), 
        ConvertToHex = (r, g, b) =>
          let
            r1        = RGB{Number.IntegerDivide(r, 16)}, 
            r2        = RGB{Number.Mod(r, 16)}, 
            g1        = RGB{Number.IntegerDivide(g, 16)}, 
            g2        = RGB{Number.Mod(g, 16)}, 
            b1        = RGB{Number.IntegerDivide(b, 16)}, 
            b2        = RGB{Number.Mod(b, 16)}, 
            HexOutput = "#" & r1 & r2 & g1 & g2 & b1 & b2
          in
            HexOutput
      in
        ConvertToHex(red, green, blue), 
    // Process the split list from the input
    RGBValues = GetColor(SplitHex), 
    RGBList = Text.Split(RGBValues, ","), 
    ColorBlindTable = CheckColorBlind(
      Number.From(RGBList{0}), 
      Number.From(RGBList{1}), 
      Number.From(RGBList{2})
    ), 
    RowsToHex = Table.TransformColumns(
      ColorBlindTable, 
      {
        {
          "P", 
          each GetHex(
            Number.From(Text.Split(_, ","){0}), 
            Number.From(Text.Split(_, ","){1}), 
            Number.From(Text.Split(_, ","){2})
          )
        }, 
        {
          "D", 
          each GetHex(
            Number.From(Text.Split(_, ","){0}), 
            Number.From(Text.Split(_, ","){1}), 
            Number.From(Text.Split(_, ","){2})
          )
        }, 
        {
          "T", 
          each GetHex(
            Number.From(Text.Split(_, ","){0}), 
            Number.From(Text.Split(_, ","){1}), 
            Number.From(Text.Split(_, ","){2})
          )
        }
      }
    ), 
    Renames = Table.RenameColumns(
      RowsToHex, 
      {{"P", "Protanomaly"}, {"D", "Deuteranomaly"}, {"T", "Tritanomaly"}}
    ), 
    Output = Table.TransformColumnTypes(
      Renames, 
      {
        {"Severity", type number}, 
        {"Protanomaly", type text}, 
        {"Deuteranomaly", type text}, 
        {"Tritanomaly", type text}
      }
    )
  in
    Output),


fnType = type function (HEX as text) as table meta 
[Documentation.Name = "CheckColorBlind",
Documentation.LongDescription = "This function returns a table of results applying different levels of severity for protanomaly, deuteranomaly, and tritanomaly color blindness.",
Documentation.Examples = {
    [Description = "This provides a table of results for the color red.",
    Code = "CheckColorBlind(""#FF0000"")",
    Result="Severity#(tab)Protanomaly#(tab)Deuteranomaly#(tab)Tritanomaly#(lf)" &
            "------------------------------------------------------------#(lf)" &
            "0#(tab)#(tab)#FF0000#(tab)#(tab)#FF0000#(tab)#(tab)#FF0000#(lf)" &
            "0.1#(tab)#(tab)#DA0701#(tab)#(tab)#DD0D01#(tab)#(tab)#EC0502#(lf)" &
            "0.2#(tab)#(tab)#BB0D01#(tab)#(tab)#C21702#(tab)#(tab)#E40803#(lf)" &
            "0.3#(tab)#(tab)#A11202#(tab)#(tab)#AC2002#(tab)#(tab)#E70703#(lf)" &
            "0.4#(tab)#(tab)#891502#(tab)#(tab)#9A2802#(tab)#(tab)#F20403#(lf)" &
            "0.5#(tab)#(tab)#751802#(tab)#(tab)#8C2E03#(tab)#(tab)#FF0202#(lf)" &
            "0.6#(tab)#(tab)#621A02#(tab)#(tab)#7F3403#(tab)#(tab)#FF0800#(lf)" &
            "0.7#(tab)#(tab)#521B02#(tab)#(tab)#753A03#(tab)#(tab)#FF0F01#(lf)" &
            "0.8#(tab)#(tab)#421C02#(tab)#(tab)#6C3F03#(tab)#(tab)#FF1401#(lf)" &
            "0.9#(tab)#(tab)#341D01#(tab)#(tab)#644303#(tab)#(tab)#FF1600#(lf)" &
            "1#(tab)#(tab)#271D01#(tab)#(tab)#5E4703#(tab)#(tab)#FF1401#(lf)"]
}]
    in  
Value.ReplaceType(CheckColorBlind, fnType)
      ],
      [
        Name = "CheckColorContrast", 
        Category = "UX", 
        Function = let CheckColorContrast = 

    Function.From(type function(HEX1 as text, HEX2 as text) as text, (params)=>

let 
    // Split strings into list by each character, convert to upper, remove hash
    H1 = if params{0} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{0}), "#")) else "#000000",
    H2 = if params{1} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{1}), "#")) else "#000000",
    
    // Split the Source by each character
    SplitHex1 = Splitter.SplitTextByRepeatedLengths(1)(H1),
    SplitHex2 = Splitter.SplitTextByRepeatedLengths(1)(H2),
    
    GetLuminance = (hexlist) => 
        // Nested let function to do all luminance calculations
        let 
                // Set exp constant
                exp= 2.4,
                
                // Build the RGB list
                RGB = List.Combine({{"0".."9"},{"A".."F"}}),

                //Get srgb sunfunction
                GetSRGB = (cval1, cval2)=>
                let 
                    SRGB = ((cval1 * 16)+ cval2)/255
                    in       
                SRGB,

                // Get final c values subfunction
                GetFinalColorVal = (srgb)=>
                    let   
                        colorval = if srgb <=0.03928 then srgb/12.92 else Number.Power(((srgb + 0.055)/1.055), exp)
                    in  
                        colorval,  

                r1 = List.PositionOf(RGB, hexlist{0}),
                r2 = List.PositionOf(RGB, hexlist{1}),
                g1 = List.PositionOf(RGB, hexlist{2}),
                g2 = List.PositionOf(RGB, hexlist{3}),
                b1 = List.PositionOf(RGB, hexlist{4}),
                b2 = List.PositionOf(RGB, hexlist{5}),

                // Calculate rsrgb, gsrgb, bsrgb
                rsrgb = GetSRGB(r1,r2),
                gsrgb = GetSRGB(g1,g2),
                bsrgb = GetSRGB(b1,b2),

                // Calculate r, g, b
                r = GetFinalColorVal(rsrgb),
                g = GetFinalColorVal(gsrgb),
                b = GetFinalColorVal(bsrgb),
    
                // Calculate luminance
                luminance = (0.2126 * r) + 
                            (0.7152 * g) + 
                            (0.0722 * b)
        in  
                luminance,

    // Determine contrast ratio
    l1 = GetLuminance(SplitHex1),
    l2 = GetLuminance(SplitHex2),

    cratio =  if l1 > l2 then (l1 + 0.05) / (l2 + 0.05) else (l2 + 0.05) / (l1 + 0.05),

    // Set min contrast
    min = 4.5,

    // Determine if it meets min
    contrast = if cratio >= min then "Enough Contrast" else "Not Enough Contrast"
   
in 
    contrast),


fnType = type function (HEX1 as text, HEX2 as text) as text meta 
[Documentation.Name = "CheckColorContrast",
Documentation.LongDescription = "This function checks if there is enough contrast between two hex codes.",
Documentation.Examples = {
    [Description = "This checks if there is enough contrast between white and black.",
    Code = "CheckColorContrast(""#FFFFFF"", ""#000000"")",
    Result="Enough Contrast"],
    [Description = "This checks if there is enough contrast between two shades of red.",
    Code = "CheckColorContrast(""#FF0000"", ""#FE0000"")",
    Result="Not Enough Contrast"]
}]
    in  
Value.ReplaceType(CheckColorContrast, fnType)
      ],
      [
        Name = "CheckWebAimContrast", 
        Category = "UX", 
        Function = let
  // Define the function using Function.From
  CheckWebAimContrast = Function.From(
    type function (background_hex as text, font_hex as text) as text,
    (params) =>
      let
        // Nested function to remove leading hash for API call and to check length and prevent errors
        remove_hash = (hex as text) =>
          let
            // Trim any spaces
            trim = Text.Trim(hex), 
            // Remove leading hash
            remove = if Text.StartsWith(trim, "#") then Text.RemoveRange(trim, 0, 1) else trim, 
            // Check length, set to white if not equal to 6
            check_length = if Text.Length(remove) <> 6 then "#FFFFFF" else remove
          in
            check_length, 

        // Pass background color
        bg = remove_hash(params{0}), 
        // Pass font color 
        font = remove_hash(params{1}), 

        // Call the API
        Call = Json.Document(
          Web.Contents(
            "https://webaim.org/resources/contrastchecker/?fcolor=" & font & "&bcolor=" & bg & "&api"
          )
        ), 

        // If any fail, transform the record field to be more descriptive, else null 
        Transform = Record.TransformFields(
          Call, 
          {
            {"AA", each if _ = "fail" then "WCAG 2.0 Level AA Normal Font Test Failed" else null}, 
            {"AALarge", each if _ = "fail" then "WCAG 2.0 Level AA Large Font Test Failed" else null}, 
            {"AAA", each if _ = "fail" then "WCAG 2.0 Level AAA Normal Font Test Failed" else null}, 
            {"AAALarge", each if _ = "fail" then "WCAG 2.0 Level AAA Large Font Test Failed" else null}
          }
        ), 

        // Filter out tests that passed 
        Select = List.Select(Record.ToList(Transform), each _ <> null), 

        // Concatenate the ratio and any failures
        Concat = List.Accumulate(
          Select, 
          "", 
          (state, current) =>
            if List.PositionOf(Select, current) = 0 then
              Text.Combine({"Ratio: ", Text.From(current), " to 1#(lf)"})
            else if List.PositionOf(Select, current) = 1 then
              Text.Combine({state, "Test Failures:#(lf)", current, "#(lf)"})
            else
              Text.Combine({state, current, "#(lf)"})
        ), 

        // If all pass then let the user know
        If_All_Pass = 
          if Text.Contains(Concat, "Test Failures") = false then
            Text.Combine({Concat, "Test Failures: None"})
          else
            Concat
      in
        If_All_Pass
  ),

  // Define the function type with metadata
  fnType = type function (background_hex as text, font_hex as text) as text
    meta [
      Documentation.Name = "CheckWebAimContrast", 
      Documentation.LongDescription = "Check the WebAim API using background and font color hex codes and return the contrast ratio and any test results that failed.", 
      Documentation.Examples = {
        [
          Description = "This checks for #FFFFFF (white background) and #000000 (black font).", 
          Code        = "=CheckWebAimContrast(""#FFFFFF"", ""#000000"")", 
          Result      = "Ratio: 21 to 1#(lf)Test Failures: None"
        ], 
        [
          Description = "This checks for #FFFFFF (white background) and #FFFFFF (white font).", 
          Code        = "=CheckWebAimContrast(""#FFFFFF"", ""#FFFFFF"")", 
          Result      = "Ratio: 1 to 1#(lf)Test Failures:#(lf)WCAG 2.0 Level AA Normal Font Test Failed#(lf)WCAG 2.0 Level AA Large Font Test Failed#(lf)WCAG 2.0 Level AAA Normal Font Test Failed#(lf)WCAG 2.0 Level AAA Large Font Test Failed"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(CheckWebAimContrast, fnType)

      ],
      [
        Name = "GetColorHue", 
        Category = "UX", 
        Function = let
  GetColorHue = Function.From(
    type function (HEX as text) as number, 
    (params) =>
      let
        // Split strings into list by each character, convert to upper, remove hash
        Source = if params{0} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{0}), "#")) else "#000000",
        
        // Split the Source by each character
        SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

        GetHue = (hexlist) =>
          let 
            // Build the RGB list
            RGB = List.Combine({{"0".."9"},{"A".."F"}}),
            
            // Sub function to figure out RGB value
            GetRGB = (cval1, cval2) =>
              let 
                RGBVal = (Number.From(cval1) * 16) + Number.From(cval2)
              in       
                RGBVal,
            
            // Get positions of each digit
            r = GetRGB(List.PositionOf(RGB, hexlist{0}), List.PositionOf(RGB, hexlist{1})),
            g = GetRGB(List.PositionOf(RGB, hexlist{2}), List.PositionOf(RGB, hexlist{3})),
            b = GetRGB(List.PositionOf(RGB, hexlist{4}), List.PositionOf(RGB, hexlist{5})),
            
            // Get the hue from r, g, b values
            hue = 
              if r >= g and g >= b then 60 * (g - b) / (r - b)
              else if g > r and r >= b then 60 * (2 - (r - b) / (g - b))
              else if g >= b and b > r then 60 * (2 + (b - r) / (g - r))
              else if b > g and g > r then 60 * (4 - (g - r) / (b - r))
              else if b > r and r >= g then 60 * (4 + (r - g) / (b - g))
              else if r >= b and b > g then 60 * (6 - (b - g) / (r - g))
              else -1
          in
            hue,
        
        // Process the split list from the input
        Result = GetHue(SplitHex)
      in
        Result
  ), 
  fnType = type function (HEX as text) as number
    meta [
      Documentation.Name = "GetColorHue", 
      Documentation.LongDescription = "This function calculates the hue of a color given its HEX code.", 
      Documentation.Examples = {
        [
          Description = "Calculate the hue of a color given its HEX code.",
          Code        = "=GetColorHue(""#FF5733"")", 
          Result      = "10.588235294117647"
        ]
      }
    ]
in
  Value.ReplaceType(GetColorHue, fnType)

      ],
      [
        Name = "GetColorScheme", 
        Category = "UX", 
        Function = //from the color api: https://www.thecolorapi.com/docs
let
  GetColorScheme = Function.From(
    type function (hex as text, mode as number, count as number) as table, 
    (params) =>
      let
        num = Text.From(params{2}), 
        hx = if Text.StartsWith(params{0}, "#") then Text.Replace(params{0}, "#", "") else params{0}, 
        md = 
          if params{1} = 0 then
            "monochrome"
          else if params{1} = 1 then
            "monochrome-dark"
          else if params{1} = 2 then
            "monochrome-light"
          else if params{1} = 3 then
            "analogic"
          else if params{1} = 4 then
            "complement"
          else if params{1} = 5 then
            "analogic-complement"
          else if params{1} = 6 then
            "triad"
          else if params{1} = 7 then
            "quad"
          else 
            "monochrome", 
        call = Json.Document(
          Web.Contents(
            "https://www.thecolorapi.com/scheme?hex="
              & hx
              & "&format=json&mode="
              & md
              & "&count="
              & num
          )
        )[colors], 
        to_table = Table.FromList(call, Splitter.SplitByNothing(), null, null, ExtraValues.Error), 
        expanded = Table.ExpandRecordColumn(
          to_table, 
          "Column1", 
          {"hex", "rgb", "name", "contrast"}, 
          {"hex", "rgb", "name", "contrast"}
        ), 
        expanded_hex = Table.ExpandRecordColumn(expanded, "hex", {"value"}, {"hex"}), 
        expanded_rgb = Table.ExpandRecordColumn(expanded_hex, "rgb", {"value"}, {"rgb"}), 
        expanded_contrast = Table.ExpandRecordColumn(
          expanded_rgb, 
          "contrast", 
          {"value"}, 
          {"contrast"}
        ), 
        expanded_name = Table.ExpandRecordColumn(
          expanded_contrast, 
          "name", 
          {"value", "closest_named_hex"}, 
          {"closest_name", "closest_named_hex"}
        ), 
        result = Table.TransformColumnTypes(
          expanded_name, 
          {
            {"hex", type text}, 
            {"rgb", type text}, 
            {"closest_name", type text}, 
            {"closest_named_hex", type text}, 
            {"contrast", type text}
          }
        )
      in
        result
  ), 
  // Define the function type with metadata
  fnType = type function (hex as text, mode as number, count as number) as table
    meta [
      Documentation.Name            = "GetColorScheme", 
      Documentation.LongDescription = "Get Color Scheme from the Color API."
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetColorScheme, fnType)
      ],
      [
        Name = "GetCompColor", 
        Category = "UX", 
        Function = let
  // Define the function using Function.From
  GetCompColor = Function.From(
    type function (HEX as text) as text,
    (params) =>
      let
        // Split strings into list by each character, convert to upper, remove hash
        Source = if params{0} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{0}), "#")) else "#000000",
        
        // Split the Source by each character
        SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

        // Function to calculate complimentary color
        GetCompColor = (hexlist) =>
          let 
            // Build the RGB list
            RGB = List.Combine({{"0".."9"},{"A".."F"}}),
            
            // Sub function to figure out complimentary color RGB value
            GetCompRGB = (cval1, cval2) =>
              let 
                RGBVal = 255 - ((cval1 * 16) + cval2)
              in       
                RGBVal,
            
            // Sub function to figure out complimentary color hex value
            ConvertToHex = (val) =>
              let 
                first_digit = Number.RoundDown(val / 16),
                second_digit = ((val / 16) - Number.RoundDown(val / 16)) * 16,
                both_hex = Text.Combine({RGB{first_digit}, RGB{second_digit}})
              in    
                both_hex,
            
            // Get positions of each digit
            r1 = List.PositionOf(RGB, hexlist{0}),
            r2 = List.PositionOf(RGB, hexlist{1}),
            g1 = List.PositionOf(RGB, hexlist{2}),
            g2 = List.PositionOf(RGB, hexlist{3}),
            b1 = List.PositionOf(RGB, hexlist{4}),
            b2 = List.PositionOf(RGB, hexlist{5}),

            // Process digit values 
            cred = GetCompRGB(r1, r2),
            cgreen = GetCompRGB(g1, g2),
            cblue = GetCompRGB(b1, b2),
            
            // Combine R, G, B hex values to one hex value
            FinalRGB = Text.Combine({
              "#",
              ConvertToHex(cred),
              ConvertToHex(cgreen),
              ConvertToHex(cblue)
            })
          in
            FinalRGB,
    
        // Process the split list from the input
        CompColor = GetCompColor(SplitHex)
      in
        CompColor
  ),

  // Define the function type with metadata
  fnType = type function (HEX as text) as text
    meta [
      Documentation.Name = "GetCompColor",
      Documentation.LongDescription = "This function takes a hex code and returns the complimentary color.",
      Documentation.Examples = {
        [
          Description = "This gets the complimentary color for #E8DDB5 (dutch white).",
          Code        = "=GetCompColor(""#E8DDB5"")",
          Result      = "#17224A"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetCompColor, fnType)
      ],
      [
        Name = "GetFontColor", 
        Category = "UX", 
        Function = let
  // Define the function using Function.From
  GetFontColor = Function.From(
    type function (HEX as text) as text,
    (params) =>
      let
        // Split strings into list by each character, convert to upper, remove hash
        Source = if params{0} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{0}), "#")) else "#000000",
        
        // Set gamma
        gamma = 2.2,

        // Get sRGB subfunction
        GetSRGB = (cval1, cval2) =>
          let 
            SRGB = ((cval1 * 16) + cval2) / 255
          in       
            SRGB,

        // Build the RGB list
        RGB = List.Combine({{"0".."9"},{"A".."F"}}),

        // Split the Source by each character
        SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

        // Each value is essentially the index position of the RGB list
        r1 = List.PositionOf(RGB, SplitHex{0}),
        r2 = List.PositionOf(RGB, SplitHex{1}),
        g1 = List.PositionOf(RGB, SplitHex{2}),
        g2 = List.PositionOf(RGB, SplitHex{3}),
        b1 = List.PositionOf(RGB, SplitHex{4}),
        b2 = List.PositionOf(RGB, SplitHex{5}),

        // Calculate rnum, gnum, bnum
        rnum = GetSRGB(r1, r2),
        gnum = GetSRGB(g1, g2),
        bnum = GetSRGB(b1, b2),

        // Calculate luminance
        luminance = (0.2126 * Number.Power(rnum, gamma)) + 
                    (0.7152 * Number.Power(gnum, gamma)) + 
                    (0.0722 * Number.Power(bnum, gamma)),

        // Determine font color
        fontcolor = if luminance > 0.5 then "#FFFFFF" else "#000000"
      in 
        fontcolor
  ),

  // Define the function type with metadata
  fnType = type function (HEX as text) as text
    meta [
      Documentation.Name = "GetFontColor",
      Documentation.LongDescription = "This function takes a hex code and returns whether the font should be black or white hex codes for readability.",
      Documentation.Examples = {
        [
          Description = "This gets the font color for #666A86.",
          Code        = "=GetFontColor(""#666A86"")",
          Result      = "#000000"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetFontColor, fnType)

      ],
      [
        Name = "GetHexValue", 
        Category = "UX", 
        Function = let
  // Define the function using Function.From
  GetHexValue = Function.From(
    type function (red as number, green as number, blue as number) as text,
    (params) =>
      let
        // Build the RGB list
        RGB = List.Combine({{"0" .. "9"}, {"A" .. "F"}}), 
        
        // Function to convert RGB values to hex
        ConvertToHex = (r, g, b) =>
          let
            r1        = RGB{Number.IntegerDivide(r, 16)}, 
            r2        = RGB{Number.Mod(r, 16)}, 
            g1        = RGB{Number.IntegerDivide(g, 16)}, 
            g2        = RGB{Number.Mod(g, 16)}, 
            b1        = RGB{Number.IntegerDivide(b, 16)}, 
            b2        = RGB{Number.Mod(b, 16)}, 
            HexOutput = "#" & r1 & r2 & g1 & g2 & b1 & b2
          in
            HexOutput
      in 
        ConvertToHex(params{0}, params{1}, params{2})
  ),

  // Define the function type with metadata
  fnType = type function (red as number, green as number, blue as number) as text
    meta [
      Documentation.Name = "GetHexValue",
      Documentation.LongDescription = "This function converts RGB values to hex codes.",
      Documentation.Examples = {
        [
          Description = "This converts 255, 255, 255 to hex.",
          Code        = "=GetHexValue(255, 255, 255)",
          Result      = "#FFFFFF"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(GetHexValue, fnType)

      ],
      [
        Name = "GetLuminosity", 
        Category = "UX", 
        Function = let
  GetLuminosity = Function.From(
    type function (HEX as text) as number, 
    (params) =>
      let
        // Split strings into list by each character, convert to upper, remove hash
        Source = if params{0} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{0}), "#")) else "#000000",
        
        // Split the Source by each character
        SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

        GetLuminosity = (hexlist) =>
          let 
            // Build the RGB list
            RGB = List.Combine({{"0".."9"},{"A".."F"}}),
            
            // Sub function to figure out complimentary color RGB value
            GetRGB = (cval1, cval2) =>
              let 
                RGBVal = (Number.From(cval1) * 16) + Number.From(cval2)
              in       
                RGBVal,
            
            // Get positions of each digit
            r = GetRGB(List.PositionOf(RGB, hexlist{0}), List.PositionOf(RGB, hexlist{1})),
            g = GetRGB(List.PositionOf(RGB, hexlist{2}), List.PositionOf(RGB, hexlist{3})),
            b = GetRGB(List.PositionOf(RGB, hexlist{4}), List.PositionOf(RGB, hexlist{5})),
            
            // Combine R, G, B hex values to one hex value
            FinalRGB = {r, g, b},
            
            // Get the luminosity
            Luminosity = 0.5 * (List.Max(FinalRGB) / 255 + List.Min(FinalRGB) / 255)
          in
            Luminosity,
        
        // Process the split list from the input
        lum = GetLuminosity(SplitHex)
      in
        lum
  ), 
  fnType = type function (HEX as text) as number
    meta [
      Documentation.Name = "GetLuminosity", 
      Documentation.LongDescription = "This function calculates the luminosity of a color given its HEX code.", 
      Documentation.Examples = {
        [
          Description = "Calculate the luminosity of a color given its HEX code.",
          Code        = "=GetLuminosity(""#FF5733"")", 
          Result      = "0.6"
        ]
      }
    ]
in
  Value.ReplaceType(GetLuminosity, fnType)

      ],
      [
        Name = "GetRGBValue", 
        Category = "UX", 
        Function = let 
    GetRGBValue = 

// Calculate RGB based on hex value
(HEX as text)=>

let 
    // Split strings into list by each character, convert to upper, remove hash
    Source = if HEX <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX), "#")) else "#000000",
    
    // Split the Source by each character
    SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

    GetColor = (hexlist)=>

        let 
            // Build the RGB list
            RGB = List.Combine({{"0".."9"},{"A".."F"}}),
            
            // Sub function to figure out RGB value
            GetRGB = (cval1, cval2)=>
            let 
                RGBVal = (Number.From(cval1) * 16)+ Number.From(cval2)
            in       
                RGBVal,
            
            
            // Get positions of each digit
            r = GetRGB(List.PositionOf(RGB,hexlist{0}), List.PositionOf(RGB, hexlist{1})),
            g = GetRGB(List.PositionOf(RGB, hexlist{2}), List.PositionOf(RGB, hexlist{3})),
            b = GetRGB(List.PositionOf(RGB,hexlist{4}), List.PositionOf(RGB,hexlist{5})),

            
            // Combine R,G,B hex values to one hex value
            FinalRGB = Text.Combine({Text.From(r), Text.From(g), Text.From(b)}, ",")
        in
            FinalRGB,
    
    // Process the split list from the input
    RGBValues = GetColor(SplitHex)

    in

RGBValues,
    
fnType = type function (HEX as text) as text meta
[Documentation.Name = "GetRGBValue",
Documentation.LongDescription = "This is a function that converts a hex code to RGB values.",
Documentation.Examples = {
    [Description = "This converts #FFFFFF to RGB.",
    Code = "GetRGBValue(""#FFFFFF"")",
    Result="255,255,255"]
}] 

    in  
Value.ReplaceType(GetRGBValue, fnType)
      ],
      [
        Name = "MedianAspectRatio", 
        Category = "UX", 
        Function = let
  MedianAspectRatio = Function.From(
    type function (x as list, y as list) as record, 
    (params) =>
      let
        // Get the range of the x series/column by subtracting max from min
        range_x = List.Max(params{0}) - List.Min(params{0}), 
        
        // Get the range of the y series/column by subtracting max from min
        range_y = List.Max(params{1}) - List.Min(params{1}), 
        
        // Get max index of one of the columns for List.Generate
        max = List.Count(params{0}) - 1, 
        
        // The equation asks for running differences (think lag in SQL) divided by the range for x and y
        acc = List.Generate(
          () => [i = 0, dx = 0, dy = 0], 
          each [i] < max, 
          each [i = [i] + 1, dx = (params{0}{[i] + 1} - params{0}{[i]}) / range_x, dy = (params{1}{[i] + 1} - params{1}{[i]}) / range_y]
        ), 
        
        // Then divide each dx and dy. After that, take the absolute value
        div = List.Transform(
          List.Skip(acc, 1), 
          each Number.Abs(Record.Field(_, "dy") / Record.Field(_, "dx"))
        ), 
        
        // Get the median of those values
        median = List.Median(div), 
        
        // Get aspect ratio
        a = (1 / median)
      in
        // Return a record with aspect ratio and median absolute slope
        [aspect_ratio = a, median_slope = median]
  ), 
  fnType = type function (x as list, y as list) as record
    meta [
      Documentation.Name = "MedianAspectRatio", 
      Documentation.LongDescription = "This function calculates the median aspect ratio for charts based on two lists of numbers.", 
      Documentation.Examples = {
        [
          Description = "Calculate the median aspect ratio for two lists of numbers.",
          Code        = "=MedianAspectRatio({1, 2, 3, 4}, {4, 5, 6, 7})", 
          Result      = "[aspect_ratio = 1, median_slope = 1]"
        ]
      }
    ]
in
  Value.ReplaceType(MedianAspectRatio, fnType)

      ]
    },
    type table [Name = Text.Type, Category = Text.Type, Function = Function.Type]
  )
in
  return

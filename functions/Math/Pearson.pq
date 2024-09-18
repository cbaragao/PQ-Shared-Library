let
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

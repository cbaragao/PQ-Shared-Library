let
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

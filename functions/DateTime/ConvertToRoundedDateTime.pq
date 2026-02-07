let
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
  
  fnType = type function (dt as datetime, interval as number, optional culture as nullable text) as datetime
    meta [
      Documentation.Name = "ConvertToRoundedDateTime", 
      Documentation.LongDescription = "This function rounds a datetime to a specified minute interval (e.g., round to the nearest 15 minutes). Optional culture parameter defaults to 'en-US' if not specified.", 
      Documentation.Examples = {
        [
          Description = "Round a datetime to the nearest 15 minutes.",
          Code        = "ConvertToRoundedDateTime(#datetime(2022, 10, 1, 10, 17, 55), 15)", 
          Result      = "#datetime(2022, 10, 1, 10, 15, 0)"
        ]
      }
    ]
in
  Value.ReplaceType(ConvertToRoundedDateTime, fnType)

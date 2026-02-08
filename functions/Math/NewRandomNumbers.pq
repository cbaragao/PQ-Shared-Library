let
  NewRandomNumbers = (
    sample as number,
    seed as number,
    max as number
  ) as list =>
    let
      // Calculate the number of zeros needed based on the max value
      len = Text.Length(Text.From(max, "en-US")) - 1,
      
      // Generate zeros as text
      zeros = Text.Repeat("0", len),
      
      // Append zeros after a 1 and then convert to number
      places = Number.FromText("1" & zeros, "en-US"),

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
                List.Random(sample, seed), 
                // Convert to integers
                each Number.RoundAwayFromZero(_ * places, 0)
              )
            ), 
            Order.Ascending
          ), 
          each _ <= max
        )
    in  
      generate,
  
  fnType = type function (sample as number, seed as number, max as number) as list
    meta [
      Documentation.Name = "NewRandomNumbers", 
      Documentation.LongDescription = "Generates a sorted list of distinct random integers up to a specified maximum value using a seed for reproducibility.<br/><br/>Parameters:<br/>• sample (number): Number of random values to generate initially (actual result may be fewer after deduplication and filtering)<br/>• seed (number): Seed value for the random number generator (same seed produces same results)<br/>• max (number): Maximum value for generated numbers (inclusive)<br/><br/>Returns a sorted list of distinct random integers between 0 and max.",
      Documentation.Examples = {
        [
          Description = "Generate random numbers up to 100 with seed 12345",
          Code        = "NewRandomNumbers(10, 12345, 100)", 
          Result      = "{7, 8, 17, 27, 51, 52, 74, 78, 80, 83}"
        ]
      }
    ]
in
  Value.ReplaceType(NewRandomNumbers, fnType)
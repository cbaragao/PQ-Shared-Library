let
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
                  each Number.Round(_ * places, 0)
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
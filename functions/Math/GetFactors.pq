let
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
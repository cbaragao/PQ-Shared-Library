let
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
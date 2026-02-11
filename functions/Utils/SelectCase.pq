let
  SelectCase = (value as any, l as list, default as any) as any =>
      let
        // Function to select nth item of list
        // If you pass in zero, you get even indices (predicates)
        // If you pass in one, you get odd indices (results)
        fnSelectEvenOdd = (lst as list, remainder as number) as list =>
            let 
                    result = List.Select(
                      lst,
                      each Number.Mod(
                        List.PositionOf(lst, _, Occurrence.First),
                        2
                      ) = remainder
                    )
            in    
                result,
        
        // After getting even and odd in separate lists, zip them together
        // This sets up a {predicate function, return value} pair
        Zipped = List.Zip({
          fnSelectEvenOdd(l, 0), 
          fnSelectEvenOdd(l, 1)
        }),

        // Now check each predicate function and return the result that maps along with it
        // Try to find the first matching predicate, otherwise return the default
        Return = try 
          List.Select(
            List.Transform(
              Zipped, 
              each if _{0}(value) = true then _{1} else null
            ), 
            each _ <> null
          ){0} 
        otherwise 
          default
      in
       Return,
       
  fnType = type function (value as any, l as list, default as any) as any
    meta [
      Documentation.Name = "Select-Case", 
      Documentation.LongDescription = "Evaluates a value against a list of predicate functions and returns the corresponding result. The list parameter should contain alternating predicate functions and result values: {predicate1, result1, predicate2, result2, ...}. Returns the first matching result, or the default value if no predicates match. This function implements a pattern-matching or switch-case behavior in Power Query.",
      Documentation.Examples = {
        [
          Description = "Evaluate a value against a list of predicates and return the corresponding result.",
          Code        = "SelectCase(5, {each _ < 10, ""Less than 10"", each _ >= 10, ""10 or more""}, ""No match"")", 
          Result      = """Less than 10"""
        ],
        [
          Description = "Evaluate a value that matches the second predicate.",
          Code        = "SelectCase(15, {each _ < 10, ""Less than 10"", each _ >= 10, ""10 or more""}, ""No match"")", 
          Result      = """10 or more"""
        ],
        [
          Description = "Evaluate a value with no matching predicate, returning the default.",
          Code        = "SelectCase(""test"", {each _ = 123, ""Is number"", each _ = true, ""Is boolean""}, ""Unknown type"")", 
          Result      = """Unknown type"""
        ]
      }
    ]
in
  Value.ReplaceType(SelectCase, fnType)
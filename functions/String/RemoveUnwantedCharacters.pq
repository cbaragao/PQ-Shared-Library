let
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
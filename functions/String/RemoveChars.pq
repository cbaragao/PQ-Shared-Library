let
  RemoveChars = (
    str as text, 
    optional keep_upper as logical, 
    optional keep_lower as logical, 
    optional keep_nums as logical, 
    optional keep_specials as logical, 
    optional keep_chars as text
  ) as text =>
    let
      // Default values
      keep_upper_val = keep_upper ?? true,
      keep_lower_val = keep_lower ?? true,
      keep_nums_val = keep_nums ?? true,
      keep_specials_val = keep_specials ?? false,
      keep_chars_val = keep_chars ?? "",
      
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
      
      // Convert characters to keep into a list of their ASCII values
      chars_to_keep = if Text.Length(keep_chars_val) > 0 then List.Transform(Text.ToList(keep_chars_val), each Character.ToNumber(_)) else {},
      
      // Determine if uppercase letters should be removed
      u = if keep_upper_val = true then {} else upper,
      
      // Determine if lowercase letters should be removed
      l = if keep_lower_val = true then {} else lower,
      
      // Determine if numbers should be removed
      n = if keep_nums_val = true then {} else nums,
      
      // Determine if special characters should be removed
      s = if keep_specials_val = true then {} else specials,
      
      // Create a list of characters to remove, excluding those to keep
      remove_list = List.Distinct(List.RemoveItems(List.Combine({u, l, n, s}), chars_to_keep)),
      
      // Remove characters from the string
      result = Text.Combine(
        List.Select(
          Text.ToList(str), 
          each List.Contains(remove_list, Character.ToNumber(_)) = false
        ), 
        ""
      )
    in
      result, 
  fnType = type function (str as text, optional keep_upper as logical, optional keep_lower as logical, optional keep_nums as logical, optional keep_specials as logical, optional keep_chars as text) as text
    meta [
      Documentation.Name = "RemoveChars", 
      Documentation.LongDescription = "This function removes unwanted characters from a text string based on specified options. It can keep or remove uppercase letters, lowercase letters, numbers, special characters, and additional specified characters. Optional parameters default to keeping uppercase (true), lowercase (true), numbers (true), and removing special characters (false).",
      Documentation.Examples = {
        [
          Description = "Remove all characters except lowercase letters and numbers.",
          Code        = "RemoveChars(""H3ll0! Th!s 1s @ t3st."", false, true, true, false, """")", 
          Result      = "3ll0hs1st3st"
        ],
        [
          Description = "Keep only alphanumeric characters (remove all specials).",
          Code        = "RemoveChars(""User@123!#$%"", true, true, true, false, """")",
          Result      = "User123"
        ]
      }
    ]
in
  Value.ReplaceType(RemoveChars, fnType)
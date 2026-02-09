let
  // Function being tested
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
  
  // Test cases
  Source = #table(
    {"TestCase", "Input", "KeepUpper", "KeepLower", "KeepNums", "KeepSpecials", "KeepChars", "Expected", "Actual", "Pass"},
    {
      {
        "Example 1: Remove uppercase, keep lowercase and numbers",
        "H3ll0! Th!s 1s @ t3st.",
        false,
        true,
        true,
        false,
        "",
        "3ll0hs1st3st",
        RemoveChars("H3ll0! Th!s 1s @ t3st.", false, true, true, false, ""),
        RemoveChars("H3ll0! Th!s 1s @ t3st.", false, true, true, false, "") = "3ll0hs1st3st"
      },
      {
        "Example 2: Keep only alphanumeric characters",
        "User@123!#$%",
        true,
        true,
        true,
        false,
        "",
        "User123",
        RemoveChars("User@123!#$%", true, true, true, false, ""),
        RemoveChars("User@123!#$%", true, true, true, false, "") = "User123"
      },
      {
        "Test defaults: All parameters omitted should keep alpha and nums",
        "Hello123!@#",
        null,
        null,
        null,
        null,
        null,
        "Hello123",
        RemoveChars("Hello123!@#"),
        RemoveChars("Hello123!@#") = "Hello123"
      },
      {
        "Test keep only numbers",
        "Price: $19.99",
        false,
        false,
        true,
        false,
        "",
        "1999",
        RemoveChars("Price: $19.99", false, false, true, false, ""),
        RemoveChars("Price: $19.99", false, false, true, false, "") = "1999"
      },
      {
        "Test keep specific special characters (@, .)",
        "email@test.com",
        true,
        true,
        true,
        false,
        "@.",
        "email@test.com",
        RemoveChars("email@test.com", true, true, true, false, "@."),
        RemoveChars("email@test.com", true, true, true, false, "@.") = "email@test.com"
      },
      {
        "Test keep all including specials",
        "Test!@# 123",
        true,
        true,
        true,
        true,
        "",
        "Test!@# 123",
        RemoveChars("Test!@# 123", true, true, true, true, ""),
        RemoveChars("Test!@# 123", true, true, true, true, "") = "Test!@# 123"
      },
      {
        "Test empty string",
        "",
        true,
        true,
        true,
        false,
        "",
        "",
        RemoveChars("", true, true, true, false, ""),
        RemoveChars("", true, true, true, false, "") = ""
      }
    }
  )
in
  Source

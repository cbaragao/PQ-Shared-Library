let
  SplitByCharacterType = (string as text) as list =>
    let
      alpha = List.Combine({{"A".."Z"}, {"a".."z"}}),
      numeric = {"0".."9"},
      specials = List.Transform(
        List.RemoveItems({0..255}, List.Combine({{65..90}, {97..122}, {48..57}})),
        each Character.FromNumber(_)
      ),
      SplitAndCombine = (values as list, before as list, after as list) as list =>
        List.Combine(List.Transform(values, each Splitter.SplitTextByCharacterTransition(before, after)(_))),
      alphaNumeric = Splitter.SplitTextByCharacterTransition(alpha, numeric)(string),
      numericAlpha = SplitAndCombine(alphaNumeric, numeric, alpha),
      alphaSpecial = SplitAndCombine(numericAlpha, alpha, specials),
      specialAlpha = SplitAndCombine(alphaSpecial, specials, alpha),
      numericSpecial = SplitAndCombine(specialAlpha, numeric, specials),
      specialNumeric = SplitAndCombine(numericSpecial, specials, numeric),
      result = List.Transform(
        specialNumeric,
        each [
          Value = _,
          Type =
            if List.Contains(alpha, Text.Start(_, 1)) then "Alpha"
            else if List.Contains(numeric, Text.Start(_, 1)) then "Numeric"
            else if List.Contains(specials, Text.Start(_, 1)) then "Special"
            else "Unknown"
        ]
      )
    in
      result,
  fnType = type function (string as text) as list
    meta [
      Documentation.Name = "SplitByCharacterType",
      Documentation.LongDescription = "Tokenizes a text value into a list of records representing consecutive runs of Alpha (A-Z, a-z), Numeric (0-9), and Special (all other characters with code points 0 to 255) characters. Splits at every transition between these three character types using repeated passes of Splitter.SplitTextByCharacterTransition, then classifies each resulting token. Each record has a Value field with the token text and a Type field of ""Alpha"", ""Numeric"", ""Special"", or ""Unknown"" (produced only when a token starts with a character outside the recognized code point range, such as extended Unicode). Classification is intentionally ASCII/Latin-1 based and optimized for common business data patterns (invoice numbers, product codes, IDs, emails, URLs) rather than full Unicode script support.",
      Documentation.Examples = {
        [
          Description = "Tokenize an invoice number into alpha, special, and numeric runs.",
          Code = "SplitByCharacterType(""INV-2025-00123"")",
          Result = "{[Value = ""INV"", Type = ""Alpha""], [Value = ""-"", Type = ""Special""], [Value = ""2025"", Type = ""Numeric""], [Value = ""-"", Type = ""Special""], [Value = ""00123"", Type = ""Numeric""]}"
        ],
        [
          Description = "Tokenize an email address into alternating alpha and special runs.",
          Code = "SplitByCharacterType(""user@example.com"")",
          Result = "{[Value = ""user"", Type = ""Alpha""], [Value = ""@"", Type = ""Special""], [Value = ""example"", Type = ""Alpha""], [Value = ""."", Type = ""Special""], [Value = ""com"", Type = ""Alpha""]}"
        ]
      }
    ]
in
  Value.ReplaceType(SplitByCharacterType, fnType)

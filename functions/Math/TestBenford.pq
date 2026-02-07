let
  TestBenford = (num as number, optional culture as nullable text) as record =>
    let
      _culture = culture ?? "en-US",
      len = Text.Length(Text.From(num, _culture)),
      first  = if len >= 1 then Number.From(Text.ToList(Text.From(num, _culture)){0}, _culture) else null, 
      second = if len >= 2 then Number.From(Text.ToList(Text.From(num, _culture)){1}, _culture) else null, 
      third  = if len >= 3 then Number.From(Text.ToList(Text.From(num, _culture)){2}, _culture) else null, 
      d1     = try Number.Log10(1 + (1 / first)) otherwise null, 
      d2     = try Number.Log10(1 + (1 / ((10 * first) + second))) otherwise null, 
      d3     = try Number.Log10(1 + (1 / ((100 * first) + (10 * second) + third))) otherwise null, 
      result = [Digit_One = d1, Digit_Two = d2, Digit_Three = d3]
    in
      result,
  
  fnType = type function (num as number, optional culture as nullable text) as record
    meta [
      Documentation.Name = "Test-Benford",
      Documentation.LongDescription = "Tests if a number follows Benford's Law by calculating the expected probability for the first three digits. Benford's Law states that in many naturally occurring datasets, leading digits follow a logarithmic distribution where 1 appears as the first digit about 30% of the time, 2 about 18%, and so on. Returns a record with Digit_One, Digit_Two, and Digit_Three fields containing the expected probability for each digit position. Optional culture parameter defaults to 'en-US' if not specified.",
      Documentation.Examples = {
        [
          Description = "Test a 3-digit number",
          Code = "Test-Benford(123)",
          Result = "[Digit_One = 0.30103, Digit_Two = 0.03476, Digit_Three = 0.00352]"
        ],
        [
          Description = "Test a single-digit number",
          Code = "Test-Benford(5)",
          Result = "[Digit_One = 0.07918, Digit_Two = null, Digit_Three = null]"
        ]
      }
    ]
in
  Value.ReplaceType(TestBenford, fnType)
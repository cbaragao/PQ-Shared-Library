let
    // Function being tested (self-contained)
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
    
    // Test cases
    Source = #table(
        {"TestCase", "Input", "Expected_D1", "Expected_D2", "Expected_D3", "Actual", "Actual_D1", "Actual_D2", "Actual_D3", "Pass"},
        {
            {
                "Test 3-digit number (123)",
                123,
                0.30103,
                0.03476,
                0.00352,
                TestBenford(123),
                TestBenford(123)[Digit_One],
                TestBenford(123)[Digit_Two],
                TestBenford(123)[Digit_Three],
                // Check if values are approximately equal (within 0.001)
                Number.Abs(TestBenford(123)[Digit_One] - 0.30103) < 0.001
                and Number.Abs(TestBenford(123)[Digit_Two] - 0.03476) < 0.001
                and Number.Abs(TestBenford(123)[Digit_Three] - 0.00352) < 0.001
            },
            {
                "Test single-digit number (5)",
                5,
                0.07918,
                null,
                null,
                TestBenford(5),
                TestBenford(5)[Digit_One],
                TestBenford(5)[Digit_Two],
                TestBenford(5)[Digit_Three],
                // Check if D1 is approximately equal and D2/D3 are null
                Number.Abs(TestBenford(5)[Digit_One] - 0.07918) < 0.001
                and TestBenford(5)[Digit_Two] = null
                and TestBenford(5)[Digit_Three] = null
            },
            {
                "Test 2-digit number (42)",
                42,
                0.09691,
                0.01021,
                null,
                TestBenford(42),
                TestBenford(42)[Digit_One],
                TestBenford(42)[Digit_Two],
                TestBenford(42)[Digit_Three],
                // Check if D1 and D2 are approximately equal and D3 is null
                Number.Abs(TestBenford(42)[Digit_One] - 0.09691) < 0.001
                and Number.Abs(TestBenford(42)[Digit_Two] - 0.01021) < 0.001
                and TestBenford(42)[Digit_Three] = null
            }
        }
    )
in
    Source

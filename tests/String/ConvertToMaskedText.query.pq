let
  // Include function being tested
  ConvertToMaskedText = (
    string as text,
    mask as text,
    start as function,
    end as function,
    optional start_occurrence as number,
    optional end_occurrence as number
  ) as text =>
    let
      ToList = Text.ToList(string),
      StartFlags = List.Transform(ToList, each start(_)),
      EndFlags = List.Transform(ToList, each end(_)),
      FirstMask = List.PositionOf(StartFlags, true, start_occurrence ?? Occurrence.First),
      LastMask = List.PositionOf(EndFlags, true, end_occurrence ?? Occurrence.Last),
      Acc =
        // No masking when a boundary isn't found
        if FirstMask = -1 or LastMask = -1 then
          ToList
        else
          let
            l = ToList,
            first = FirstMask,
            last = LastMask,
            m = mask
          in
            List.Transform(
              {0..List.Count(ToList) - 1},
              each if _ > first and _ < last
              then m
              else l{_}
            ),
      Result = Text.Combine(Acc, "")
    in
      Result,

  // Test 1a: Mask the domain name of an email address between the "@" and the final "."
  Test1a_Result = ConvertToMaskedText("john.smith@contoso.com", "*", each _ = "@", each _ = "."),
  Test1a_Pass = Test1a_Result = "john.smith@*******.com",

  // Test 1: Mask everything strictly between the first and last hyphen
  Test1_Result = ConvertToMaskedText("INV-2025-00123", "*", each _ = "-", each _ = "-"),
  Test1_Pass = Test1_Result = "INV-****-00123",

  // Test 2: Mask everything strictly inside a pair of parentheses
  Test2_Result = ConvertToMaskedText("Customer(12345)Name", "*", each _ = "(", each _ = ")"),
  Test2_Pass = Test2_Result = "Customer(*****)Name",

  // Test 3: Adjacent boundaries (no characters strictly between them) mask nothing
  Test3_Result = ConvertToMaskedText("A-B", "*", each _ = "-", each _ = "-"),
  Test3_Pass = Test3_Result = "A-B",

  // Test 4: A multi-character mask is repeated once per masked character, not length-preserving
  Test4_Result = ConvertToMaskedText("(1234)", "**", each _ = "(", each _ = ")"),
  Test4_Pass = Test4_Result = "(********)",

  // Test 5: Overriding end_occurrence to Occurrence.First picks the same "-" match used for the start
  // boundary, so no characters lie strictly between them
  Test5_Result = ConvertToMaskedText("1-2-3-4", "*", each _ = "-", each _ = "-", Occurrence.First, Occurrence.First),
  Test5_Pass = Test5_Result = "1-2-3-4",

  // Test 6: Neither predicate ever matches, so no boundary is found and the text is returned unchanged
  Test6_Result = ConvertToMaskedText("NoBoundaries", "*", each _ = "@", each _ = "@"),
  Test6_Pass = Test6_Result = "NoBoundaries",

  // Test 7: Only the start boundary is found, so no characters are masked and the text is returned unchanged
  Test7_Result = ConvertToMaskedText("Customer(12345Name", "*", each _ = "(", each _ = ")"),
  Test7_Pass = Test7_Result = "Customer(12345Name",

  // Consolidate test results
  TestResults = #table(
    {"TestCase", "Expected", "Pass"},
    {
      {"Test1a: Mask email domain between @ and final .", true, Test1a_Pass},
      {"Test1: Mask between first and last hyphen", true, Test1_Pass},
      {"Test2: Mask inside parentheses", true, Test2_Pass},
      {"Test3: Adjacent boundaries mask nothing", true, Test3_Pass},
      {"Test4: Multi-character mask repeats per masked character", true, Test4_Pass},
      {"Test5: end_occurrence override collapses boundaries onto the same candidate", true, Test5_Pass},
      {"Test6: No boundary match leaves text unchanged", true, Test6_Pass},
      {"Test7: Only start boundary found leaves text unchanged", true, Test7_Pass}
    }
  )
in
  TestResults

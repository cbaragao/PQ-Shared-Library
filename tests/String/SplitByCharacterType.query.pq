let
    // Include function being tested
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

    // Test 1: Invoice number - alternating alpha, special, numeric runs
    t1 = SplitByCharacterType("INV-2025-00123"),
    test1Pass =
        List.Count(t1) = 5
        and t1{0}[Value] = "INV" and t1{0}[Type] = "Alpha"
        and t1{1}[Value] = "-" and t1{1}[Type] = "Special"
        and t1{2}[Value] = "2025" and t1{2}[Type] = "Numeric"
        and t1{3}[Value] = "-" and t1{3}[Type] = "Special"
        and t1{4}[Value] = "00123" and t1{4}[Type] = "Numeric",

    // Test 2: Email address - alpha/special transitions on both sides of "@" and "."
    t2 = SplitByCharacterType("user@example.com"),
    test2Pass =
        List.Count(t2) = 5
        and t2{0}[Value] = "user" and t2{0}[Type] = "Alpha"
        and t2{1}[Value] = "@" and t2{1}[Type] = "Special"
        and t2{2}[Value] = "example" and t2{2}[Type] = "Alpha"
        and t2{3}[Value] = "." and t2{3}[Type] = "Special"
        and t2{4}[Value] = "com" and t2{4}[Type] = "Alpha",

    // Test 3: Pure alpha, mixed case - no split within the Alpha category
    t3 = SplitByCharacterType("AbCdEf"),
    test3Pass =
        List.Count(t3) = 1
        and t3{0}[Value] = "AbCdEf" and t3{0}[Type] = "Alpha",

    // Test 4: Pure numeric - single Numeric token
    t4 = SplitByCharacterType("12345"),
    test4Pass =
        List.Count(t4) = 1
        and t4{0}[Value] = "12345" and t4{0}[Type] = "Numeric",

    // Test 5: Pure special - single Special token
    t5 = SplitByCharacterType("!!!"),
    test5Pass =
        List.Count(t5) = 1
        and t5{0}[Value] = "!!!" and t5{0}[Type] = "Special",

    // Test 6: Numeric <-> Special transitions with no alpha present
    t6 = SplitByCharacterType("12-34"),
    test6Pass =
        List.Count(t6) = 3
        and t6{0}[Value] = "12" and t6{0}[Type] = "Numeric"
        and t6{1}[Value] = "-" and t6{1}[Type] = "Special"
        and t6{2}[Value] = "34" and t6{2}[Type] = "Numeric",

    // Test 7: Special <-> Alpha transitions with no numeric present
    t7 = SplitByCharacterType("@abc!"),
    test7Pass =
        List.Count(t7) = 3
        and t7{0}[Value] = "@" and t7{0}[Type] = "Special"
        and t7{1}[Value] = "abc" and t7{1}[Type] = "Alpha"
        and t7{2}[Value] = "!" and t7{2}[Type] = "Special",

    // Test 8: Numeric -> Alpha direct transition
    t8 = SplitByCharacterType("123abc"),
    test8Pass =
        List.Count(t8) = 2
        and t8{0}[Value] = "123" and t8{0}[Type] = "Numeric"
        and t8{1}[Value] = "abc" and t8{1}[Type] = "Alpha",

    // Test 9: Alpha -> Numeric direct transition (matches Microsoft Learn example)
    t9 = SplitByCharacterType("Abc123"),
    test9Pass =
        List.Count(t9) = 2
        and t9{0}[Value] = "Abc" and t9{0}[Type] = "Alpha"
        and t9{1}[Value] = "123" and t9{1}[Type] = "Numeric",

    // Test 10: Empty string - single Unknown token with an empty Value
    t10 = SplitByCharacterType(""),
    test10Pass =
        List.Count(t10) = 1
        and t10{0}[Value] = "" and t10{0}[Type] = "Unknown",

    // Test 11: Character outside the ASCII/Latin-1 range (code point > 255) classifies as Unknown
    t11 = SplitByCharacterType("日"),
    test11Pass =
        List.Count(t11) = 1
        and t11{0}[Value] = "日" and t11{0}[Type] = "Unknown",

    // Test 12: Documented limitation - an unrecognized character embedded in an Alpha run
    // does not force a split, and the token is classified by its first character
    t12 = SplitByCharacterType("abc日"),
    test12Pass =
        List.Count(t12) = 1
        and t12{0}[Value] = "abc日" and t12{0}[Type] = "Alpha",

    // Test 13: Null input errors because the parameter is typed as non-nullable text
    t13 = try SplitByCharacterType(null) otherwise null,
    test13Pass = t13 = null,

    Source = #table(
        {"TestCase", "Pass"},
        {
            {"Invoice number: alternating Alpha/Special/Numeric runs",                      test1Pass},
            {"Email address: Alpha/Special runs around @ and .",                             test2Pass},
            {"Pure alpha, mixed case: single Alpha token, no split",                         test3Pass},
            {"Pure numeric: single Numeric token",                                           test4Pass},
            {"Pure special: single Special token",                                           test5Pass},
            {"Numeric/Special transitions with no alpha present",                            test6Pass},
            {"Special/Alpha transitions with no numeric present",                            test7Pass},
            {"Numeric -> Alpha direct transition",                                           test8Pass},
            {"Alpha -> Numeric direct transition (Microsoft Learn example)",                 test9Pass},
            {"Empty string: single Unknown token with empty Value",                          test10Pass},
            {"Code point > 255 alone: classified as Unknown",                                test11Pass},
            {"Code point > 255 embedded in Alpha run: no split, classified by first char",   test12Pass},
            {"Null input: errors due to non-nullable text parameter",                        test13Pass}
        }
    )
in
    Source

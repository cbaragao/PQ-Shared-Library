let
    // Include function being tested
    SplitAndValidate = (string as text, delimiter as text, rules as list) as table =>
        let
            split = Text.Split(string, delimiter),
            zip = List.Zip({split, rules}),
            patternResults = List.Transform(zip, each _{1}[Pattern](_{0})),
            allPass = List.Contains(patternResults, false) = false,
            result = if allPass
                then Table.FromRecords(
                    List.Transform(
                        zip,
                        each Record.FromList({_{1}[Name], _{0}, true}, {"Name", "Value", "Success"})
                    )
                )
                else Table.FromRecords(
                    List.Transform(
                        List.Zip({zip, patternResults}),
                        each Record.FromList({_{0}{1}[Name], _{0}{0}, _{1}}, {"Name", "Value", "Success"})
                    )
                )
        in
            result,

    rules2 = {[Name = "Part1", Pattern = each _ = "AB"], [Name = "Part2", Pattern = each _ = "CD"]},

    // Test 1: all rules match — every row gets Success = true
    t1 = SplitAndValidate("AB,CD", ",", rules2),
    test1Pass =
        Table.RowCount(t1) = 2
        and t1{0}[Name] = "Part1" and t1{0}[Value] = "AB" and t1{0}[Success] = true
        and t1{1}[Name] = "Part2" and t1{1}[Value] = "CD" and t1{1}[Success] = true,

    // Test 2: one rule fails — passing row true, failing row false (per-row results)
    t2 = SplitAndValidate("AB,XY", ",", rules2),
    test2Pass =
        Table.RowCount(t2) = 2
        and t2{0}[Success] = true
        and t2{1}[Success] = false,

    // Test 3: all rules fail — every row false
    t3 = SplitAndValidate("ZZ,YY", ",", rules2),
    test3Pass =
        Table.RowCount(t3) = 2
        and t3{0}[Success] = false
        and t3{1}[Success] = false,

    // Test 4: single element, rule matches — Success = true
    t4 = SplitAndValidate("HELLO", ";", {[Name = "Greeting", Pattern = each _ = "HELLO"]}),
    test4Pass =
        Table.RowCount(t4) = 1
        and t4{0}[Name] = "Greeting" and t4{0}[Value] = "HELLO" and t4{0}[Success] = true,

    // Test 5: three-part split, last value mismatches — first two true, last false
    t5 = SplitAndValidate("A|B|X", "|", {[Name = "c1", Pattern = each _ = "A"], [Name = "c2", Pattern = each _ = "B"], [Name = "c3", Pattern = each _ = "C"]}),
    test5Pass =
        Table.RowCount(t5) = 3
        and t5{0}[Success] = true
        and t5{1}[Success] = true
        and t5{2}[Success] = false,

    Source = #table(
        {"TestCase", "Pass"},
        {
            {"All rules match: Success = true for all rows",                  test1Pass},
            {"One rule fails: passing rows true, failing rows false",         test2Pass},
            {"All rules fail: Success = false for all rows",                  test3Pass},
            {"Single element, rule matches: Success = true",                  test4Pass},
            {"Three-part split, last fails: first two true, last false",      test5Pass}
        }
    )
in
    Source

let
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
  fnType = type function (string as text, delimiter as text, rules as list) as table
    meta [
      Documentation.Name = "SplitAndValidate",
      Documentation.LongDescription = "Splits a text value using a delimiter and applies a named pattern rule to each resulting value. Returns a table with each rule name, the split value, and a Success flag. When every pattern passes, all rows show true. When any pattern fails, each row shows its own individual pass/fail result.",
      Documentation.Examples = {
        [
          Description = "All rules match: every row shows Success = true.",
          Code = "SplitAndValidate(""AB,CD"", "","", {[Name = ""Part1"", Pattern = each _ = ""AB""], [Name = ""Part2"", Pattern = each _ = ""CD""]})",
          Result = "#table({""Name"", ""Value"", ""Success""}, {{""Part1"", ""AB"", true}, {""Part2"", ""CD"", true}})"
        ],
        [
          Description = "One rule fails: passing rows show true, failing rows show false.",
          Code = "SplitAndValidate(""AB,XY"", "","", {[Name = ""Part1"", Pattern = each _ = ""AB""], [Name = ""Part2"", Pattern = each _ = ""CD""]})",
          Result = "#table({""Name"", ""Value"", ""Success""}, {{""Part1"", ""AB"", true}, {""Part2"", ""XY"", false}})"
        ]
      }
    ]
in
  Value.ReplaceType(SplitAndValidate, fnType)
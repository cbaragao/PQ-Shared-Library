let
  ConvertListToText = (list as list, separator as text) as text =>
    let
      textValues = List.Transform(list, each Text.From(_)),
      nonBlankValues = List.Select(textValues, each _ <> null and _ <> ""),
      result = Text.Combine(nonBlankValues, separator)
    in
      result,

  summary = #table(
    {"Test", "Result"},
    {
      {
        "Combine text values",
        if ConvertListToText({"Seattle", "WA"}, ", ") = "Seattle, WA" then "Passed" else "Failed"
      },
      {
        "Ignore null and empty values",
        if ConvertListToText({"Seattle", null, "", "WA"}, ", ") = "Seattle, WA" then "Passed" else "Failed"
      },
      {
        "Convert non-text values",
        if ConvertListToText({1, true}, "|") = "1|true" then "Passed" else "Failed"
      },
      {
        "Return empty text for an empty list",
        if ConvertListToText({}, ", ") = "" then "Passed" else "Failed"
      },
      {
        "Return a single value without a separator",
        if ConvertListToText({null, "only", ""}, ", ") = "only" then "Passed" else "Failed"
      }
    }
  )
in
  summary
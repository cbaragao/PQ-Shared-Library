let
  ConvertListToText = (list as list, separator as text) as text =>
    let
      textValues = List.Transform(list, each Text.From(_)),
      nonBlankValues = List.Select(textValues, each _ <> null and _ <> ""),
      result = Text.Combine(nonBlankValues, separator)
    in
      result,
  fnType = type function (list as list, separator as text) as text
    meta [
      Documentation.Name = "ConvertListToText",
      Documentation.LongDescription = "Converts the values in a list to text and combines the non-null, non-empty values using the supplied separator.",
      Documentation.Examples = {
        [
          Description = "Combine text values with a comma and space.",
          Code = "ConvertListToText({""Seattle"", ""WA""}, "", "")",
          Result = "Seattle, WA"
        ],
        [
          Description = "Ignore null and empty values while combining list values.",
          Code = "ConvertListToText({""Seattle"", null, """", ""WA""}, "", "")",
          Result = "Seattle, WA"
        ]
      }
    ]
in
  Value.ReplaceType(ConvertListToText, fnType)
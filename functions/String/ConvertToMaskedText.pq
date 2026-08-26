let
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

  fnType = type function (
      string as text,
      mask as text,
      start as function,
      end as function,
      optional start_occurrence as number,
      optional end_occurrence as number
    ) as text
    meta [
      Documentation.Name = "ConvertToMaskedText",
      Documentation.LongDescription = "Masks characters strictly between two boundary positions in a string of text while preserving everything outside them, including the boundary characters themselves. ""start"" and ""end"" are predicate functions evaluated against each individual character (not substrings), so they can detect single characters like ""@"", ""."", ""("", "")"", or ""-"", but not multi-character patterns. The start and end boundaries are found independently: ""start_occurrence"" selects which match of ""start"" is used as the start boundary (defaulting to Occurrence.First) and ""end_occurrence"" selects which match of ""end"" is used as the end boundary (defaulting to Occurrence.Last), so an unqualified call masks between the first character matching ""start"" and the last character matching ""end"". If either boundary isn't found, or the boundaries are the same position or adjacent, no characters are masked and the original text is returned unchanged. ""mask"" replaces every masked character one-for-one and is typically a single character, though any text value is accepted.",
      Documentation.Examples = {
        [
          Description = "Mask the domain name of an email address between the ""@"" and the final ""."".",
          Code = "ConvertToMaskedText(""john.smith@contoso.com"", ""*"", each _ = ""@"", each _ = ""."")",
          Result = "john.smith@*******.com"
        ],
        [
          Description = "Mask text between the first and last hyphen.",
          Code = "ConvertToMaskedText(""INV-2025-00123"", ""*"", each _ = ""-"", each _ = ""-"")",
          Result = "INV-****-00123"
        ],
        [
          Description = "Mask text inside parentheses.",
          Code = "ConvertToMaskedText(""Customer(12345)Name"", ""*"", each _ = ""("", each _ = "")"")",
          Result = "Customer(*****)Name"
        ]
      }
    ]
in
  Value.ReplaceType(ConvertToMaskedText, fnType)

let
  EncodeText = 
    Function.From(
      type function (str as text) as text, 
      (params) =>
        let
          // Convert each character to its ASCII number and format as a 3-digit string
          return = Text.Combine(List.Transform(Text.ToList(params{0}), each Number.ToText(Character.ToNumber(_), "000")), "")
        in
          return
    ), 
  fnType = type function (str as text) as text
    meta [
      Documentation.Name = "EncodeText",
      Documentation.LongDescription = "This function takes a text string and encodes it by converting each character to its ASCII number, formatted as a 3-digit string.",
      Documentation.Examples = {
        [
          Description = "Encode the text 'Hello'.",
          Code        = "=EncodeText(""Hello"")", 
          Result      = "072101108108111"
        ]
      }
    ]
in
  Value.ReplaceType(EncodeText, fnType)

let
  ConvertToEncodedText = (str as text) as text =>
    let
      // Convert each character to its ASCII number and format as a 3-digit string
      result = Text.Combine(
        List.Transform(
          Text.ToList(str), 
          each Number.ToText(Character.ToNumber(_), "000", "en-US")
        ), 
        ""
      )
    in
      result,
  
  fnType = type function (str as text) as text
    meta [
      Documentation.Name = "ConvertToEncodedText",
      Documentation.LongDescription = "Encodes a text string by converting each character to its ASCII number, formatted as a 3-digit string. Each character is represented by exactly 3 digits (e.g., 'A' becomes '065', space becomes '032').",
      Documentation.Examples = {
        [
          Description = "Encode the text 'Hello'.",
          Code        = "ConvertToEncodedText(\"Hello\")", 
          Result      = "072101108108111"
        ],
        [
          Description = "Encode a single character.",
          Code        = "ConvertToEncodedText(\"A\")", 
          Result      = "065"
        ]
      }
    ]
in
  Value.ReplaceType(ConvertToEncodedText, fnType)

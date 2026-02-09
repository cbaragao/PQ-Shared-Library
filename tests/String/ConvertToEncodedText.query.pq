let
    // Include function being tested
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
    
    // Test cases from Documentation.Examples plus additional edge cases
    Source = #table(
        {"TestCase", "Input", "Expected", "Actual", "Pass"},
        {
            {
                "Encode 'Hello'",
                "Hello",
                "072101108108111",
                ConvertToEncodedText("Hello"),
                ConvertToEncodedText("Hello") = "072101108108111"
            },
            {
                "Encode single character 'A'",
                "A",
                "065",
                ConvertToEncodedText("A"),
                ConvertToEncodedText("A") = "065"
            },
            {
                "Encode with space",
                "Hi There",
                "072105032084104101114101",
                ConvertToEncodedText("Hi There"),
                ConvertToEncodedText("Hi There") = "072105032084104101114101"
            },
            {
                "Encode numeric characters",
                "123",
                "049050051",
                ConvertToEncodedText("123"),
                ConvertToEncodedText("123") = "049050051"
            },
            {
                "Encode special characters",
                "!@#",
                "033064035",
                ConvertToEncodedText("!@#"),
                ConvertToEncodedText("!@#") = "033064035"
            }
        }
    )
in
    Source

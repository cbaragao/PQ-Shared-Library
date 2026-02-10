let
  // Define the function using simplified syntax
  TestWebAimContrast = (background_hex as text, font_hex as text, optional culture as nullable text) as text =>
      let
        // Use default culture if not provided
        cultureToUse = culture ?? "en-US",
        
        // Nested function to remove leading hash for API call and to check length and prevent errors
        remove_hash = (hex as text) as text =>
          let
            // Trim any spaces
            trim = Text.Trim(hex), 
            // Remove leading hash
            remove = if Text.StartsWith(trim, "#", Comparer.Ordinal) then Text.RemoveRange(trim, 0, 1) else trim, 
            // Check length, set to white if not equal to 6
            check_length = if Text.Length(remove, cultureToUse) <> 6 then "#FFFFFF" else remove
          in
            check_length, 

        // Pass background color
        bg = remove_hash(background_hex), 
        // Pass font color 
        font = remove_hash(font_hex), 

        // Call the API
        Call = Json.Document(
          Web.Contents(
            "https://webaim.org/resources/contrastchecker/?fcolor=" & font & "&bcolor=" & bg & "&api"
          )
        ), 

        // If any fail, transform the record field to be more descriptive, else null 
        Transform = Record.TransformFields(
          Call, 
          {
            {"AA", each if _ = "fail" then "WCAG 2.0 Level AA Normal Font Test Failed" else null}, 
            {"AALarge", each if _ = "fail" then "WCAG 2.0 Level AA Large Font Test Failed" else null}, 
            {"AAA", each if _ = "fail" then "WCAG 2.0 Level AAA Normal Font Test Failed" else null}, 
            {"AAALarge", each if _ = "fail" then "WCAG 2.0 Level AAA Large Font Test Failed" else null}
          }
        ), 

        // Filter out tests that passed 
        Select = List.Select(Record.ToList(Transform), each _ <> null), 

        // Concatenate the ratio and any failures
        Concat = List.Accumulate(
          Select, 
          "", 
          (state as text, current as any) as text =>
            if List.PositionOf(Select, current, Occurrence.First) = 0 then
              Text.Combine({"Ratio: ", Text.From(current, cultureToUse), " to 1#(lf)"})
            else if List.PositionOf(Select, current, Occurrence.First) = 1 then
              Text.Combine({state, "Test Failures:#(lf)", current, "#(lf)"})
            else
              Text.Combine({state, current, "#(lf)"})
        ), 

        // If all pass then let the user know
        If_All_Pass = 
          if Text.Contains(Concat, "Test Failures", Comparer.Ordinal) = false then
            Text.Combine({Concat, "Test Failures: None"})
          else
            Concat
      in
        If_All_Pass,

  // Define the function type with metadata
  fnType = type function (background_hex as text, font_hex as text, optional culture as nullable text) as text
    meta [
      Documentation.Name = "Test-WebAimContrast", 
      Documentation.LongDescription = "Tests color contrast using the WebAIM API by checking background and font color hex codes against WCAG 2.0 accessibility standards. Returns the contrast ratio and indicates which tests failed (AA/AAA levels for normal and large fonts). The function automatically validates hex codes and calls the WebAIM contrast checker API.", 
      Documentation.Examples = {
        [
          Description = "Test contrast for white background and black font (passes all tests).", 
          Code        = "TestWebAimContrast(""#FFFFFF"", ""#000000"")", 
          Result      = "Ratio: 21 to 1#(lf)Test Failures: None"
        ], 
        [
          Description = "Test contrast for white background and white font (fails all tests).", 
          Code        = "TestWebAimContrast(""#FFFFFF"", ""#FFFFFF"")", 
          Result      = "Ratio: 1 to 1#(lf)Test Failures:#(lf)WCAG 2.0 Level AA Normal Font Test Failed#(lf)WCAG 2.0 Level AA Large Font Test Failed#(lf)WCAG 2.0 Level AAA Normal Font Test Failed#(lf)WCAG 2.0 Level AAA Large Font Test Failed"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(TestWebAimContrast, fnType)

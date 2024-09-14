let
  RemoveHtmlTags = Function.From(
    type function (STRING as text) as text, 
    (params) =>
      let
        // Ensure the input string is not empty or null
        Source = if params{0} = "" or params{0} = null then "" else Text.From(params{0}),

        // Remove HTML tags and extract text
        RemoveTags = Html.Table(Source, {{"text", ":root"}}),

        // Get the text content from the first row
        GetText = RemoveTags{0}
      in
        GetText
  ), 
  fnType = type function (STRING as text) as text
    meta [
      Documentation.Name = "RemoveHtmlTags",
      Documentation.LongDescription = "This function removes HTML tags from a given text string and extracts the plain text content. It takes an HTML string as input and returns the text content.",
      Documentation.Examples = {
        [
          Description = "Remove HTML tags from a string.",
          Code        = "=RemoveHtmlTags(""<p>Hello, <b>world</b>!</p>"")", 
          Result      = "Hello, world!"
        ]
      }
    ]
in
  Value.ReplaceType(RemoveHtmlTags, fnType)
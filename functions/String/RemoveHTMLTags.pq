let
  RemoveHTMLTags = (htmlString as text, optional culture as text) as text =>
    let
      // Ensure the input string is not empty or null
      cultureValue = culture ?? "en-US",
      source = if htmlString = "" or htmlString = null then "" else Text.From(htmlString, cultureValue),

      // Remove HTML tags and extract text
      removeTags = Html.Table(source, {{"text", ":root"}}),

      // Get the text content from the first row
      result = removeTags{0}[text]
    in
      result,
  
  fnType = type function (htmlString as text, optional culture as text) as text
    meta [
      Documentation.Name = "RemoveHTMLTags",
      Documentation.LongDescription = "Removes HTML tags from a text string and extracts the plain text content. Optional culture parameter defaults to 'en-US' for consistent text conversion. Useful for cleaning HTML-formatted data or extracting readable text from web content.",
      Documentation.Examples = {
        [
          Description = "Remove HTML tags from a string.",
          Code        = "RemoveHTMLTags(""<p>Hello, <b>world</b>!</p>"")", 
          Result      = "Hello, world!"
        ],
        [
          Description = "Extract text from HTML with multiple tags.",
          Code        = "RemoveHTMLTags(""<div><h1>Title</h1><p>Content here</p></div>"")", 
          Result      = "TitleContent here"
        ]
      }
    ]
in
  Value.ReplaceType(RemoveHTMLTags, fnType)
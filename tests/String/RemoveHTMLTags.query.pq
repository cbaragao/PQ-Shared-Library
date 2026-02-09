let
    // Include function being tested
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
    
    // Test cases from Documentation.Examples plus additional scenarios
    Source = #table(
        {"TestCase", "Input", "Expected", "Actual", "Pass"},
        {
            {
                "Simple HTML tags",
                "<p>Hello, <b>world</b>!</p>",
                "Hello, world!",
                RemoveHTMLTags("<p>Hello, <b>world</b>!</p>"),
                RemoveHTMLTags("<p>Hello, <b>world</b>!</p>") = "Hello, world!"
            },
            {
                "Multiple nested tags",
                "<div><h1>Title</h1><p>Content here</p></div>",
                "TitleContent here",
                RemoveHTMLTags("<div><h1>Title</h1><p>Content here</p></div>"),
                RemoveHTMLTags("<div><h1>Title</h1><p>Content here</p></div>") = "TitleContent here"
            },
            {
                "Empty string",
                "",
                "",
                RemoveHTMLTags(""),
                RemoveHTMLTags("") = ""
            },
            {
                "Plain text (no tags)",
                "Just plain text",
                "Just plain text",
                RemoveHTMLTags("Just plain text"),
                RemoveHTMLTags("Just plain text") = "Just plain text"
            },
            {
                "HTML with attributes",
                "<a href='test.html'>Click here</a>",
                "Click here",
                RemoveHTMLTags("<a href='test.html'>Click here</a>"),
                RemoveHTMLTags("<a href='test.html'>Click here</a>") = "Click here"
            }
        }
    )
in
    Source

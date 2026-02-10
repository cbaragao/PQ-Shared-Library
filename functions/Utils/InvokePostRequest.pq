let
  // Define the function using simplified syntax
  InvokePostRequest = (SvcUrl as text, Content as text, optional ContentType as nullable text) as any =>
      let
        // Use default Content-Type if not provided
        contentTypeToUse = ContentType ?? "application/json",
        
        Response = Web.Contents(
          SvcUrl,
          [
            Content = Text.ToBinary(Content, TextEncoding.Utf8),
            // Headers can be customized via ContentType parameter
            Headers = [#"Content-Type" = contentTypeToUse]
          ]
        ),
        Json = Json.Document(Response)
      in
        Json,

  // Define the function type with metadata
  fnType = type function (
    SvcUrl as text, 
    Content as text, 
    optional ContentType as nullable text
  ) as any
    meta [
      Documentation.Name = "Invoke-PostRequest",
      Documentation.LongDescription = "Makes a POST request to a specified URL with the provided content. The function accepts a URL, content body, and optional Content-Type header (defaults to 'application/json'). Returns the parsed JSON response from the server.",
      Documentation.Examples = {
        [
          Description = "Make a POST request to a sample API with default JSON content type.",
          Code = "InvokePostRequest(""https://jsonplaceholder.typicode.com/posts"", ""{\""title\"": \""foo\"", \""body\"": \""bar\"", \""userId\"": 1}"")",
          Result = "Parsed JSON response with id field added by the server"
        ],
        [
          Description = "Make a POST request with custom Content-Type header.",
          Code = "InvokePostRequest(""https://api.example.com/data"", ""<xml>data</xml>"", ""application/xml"")",
          Result = "Response from the API with XML content type"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(InvokePostRequest, fnType)
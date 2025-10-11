let
  // Define the function using Function.From
  PostRequest = Function.From(
    type function (SvcUrl as text, Content as text) as text,
    (SvcUrl, Content) =>
      let
        Response = Web.Contents(
          SvcUrl,
          [
            Content = Text.ToBinary(Content),
            // This can be edited for different header parameters
            Headers = [#"Content-Type" = "application/json"]
          ]
        ),
        Json = Json.Document(Response)
      in
        Json
  ),

  // Define the function type with metadata
  fnType = type function (SvcUrl as text, Content as text) as text
    meta [
      Documentation.Name = "PostRequest",
      Documentation.LongDescription = "This function makes a POST request to a specified URL with the provided content.",
      Documentation.Examples = {
        [
          Description = "Make a POST request to a sample API.",
          Code = "=PostRequest(""https://jsonplaceholder.typicode.com/posts"", ""{\""title\"": \""foo\"", \""body\"": \""bar\"", \""userId\"": 1}"")",
          Result = "{""title"":""foo"",""body"":""bar"",""userId"":1,""id"":101}"
        ]
      }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(PostRequest, fnType)
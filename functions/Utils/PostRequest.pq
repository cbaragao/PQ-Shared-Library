let
  // Define the function using Function.From
  PostRequest = Function.From(

(SvcUrl as text, Content as text) as text =>
(params) =>

let

    Response= Web.Contents(params{0},

    [
        Content=Text.ToBinary(params{1}),
        // This can be edited for different header parameters
        Headers=[#"Content-Type" = "application/json"]
    ]

),

    Json = Json.Document(Response)

in

    Json),

  // Define the function type with metadata
  fnType = type function (SvcUrl as text, Content as text) as text 
    meta [
      Documentation.Name = "PostRequest",
      Documentation.LongDescription = "This function makes a POST request to a specified URL with the provided content.",
        Documentation.Examples = {
            [
            Description = "Get the name of a function.",
            Code        = "=PostRequest(""https://jsonplaceholder.typicode.com/posts"", ""{\""title\"": \""foo\"", \""body\"": \""bar\"", \""userId\"": 1}"")",
            Result      = "{""title"":""foo"",""body"":""bar"",""userId"":1,""id"":101}"
            ]
        }
    ]
in
  // Replace the type of the function with the defined type
  Value.ReplaceType(PostRequest, fnType)

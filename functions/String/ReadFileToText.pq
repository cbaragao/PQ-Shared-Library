let
  ReadFileToText = Function.From(
    type function (filepath as text) as text, 
    (params) =>
      let
        // Read the file contents as a table with one column
        file = Table.FromColumns({Lines.FromBinary(File.Contents(params{0}), null, null, 1252)}),
        
        // Combine all lines into a single text string, separated by line feeds
        return = Text.Combine(file[Column1], "#(lf)")
      in
        return
  ), 
  fnType = type function (filepath as text) as text
    meta [
      Documentation.Name = "ReadFileToText",
      Documentation.LongDescription = "This function reads the contents of a file and combines all lines into a single text string, separated by line feeds. It takes the file path as input and returns the combined text.",
      Documentation.Examples = {
        [
          Description = "Read the contents of a text file and combine all lines.",
          Code        = "=ReadFileToText(""C:\\path\\to\\file.txt"")", 
          Result      = "Combined text of the file"
        ]
      }
    ]
in
  Value.ReplaceType(ReadFileToText, fnType)

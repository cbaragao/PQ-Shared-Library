let
  GetFileText = (filepath as text) as text =>
    let
      // Read the file contents as a table with one column
      file = Table.FromColumns({Lines.FromBinary(File.Contents(filepath), null, null, 1252)}),
      
      // Combine all lines into a single text string, separated by line feeds
      result = Text.Combine(file[Column1], "#(lf)")
    in
      result,
  
  fnType = type function (filepath as text) as text
    meta [
      Documentation.Name = "GetFileText",
      Documentation.LongDescription = "Reads the contents of a file and returns all lines combined into a single text string, separated by line feeds. Useful for loading text files, logs, or configuration files into Power Query.",
      Documentation.Examples = {
        [
          Description = "Read the contents of a text file.",
          Code        = "GetFileText(""C:\\logs\\app.log"")", 
          Result      = "Combined text of the file with line breaks"
        ],
        [
          Description = "Load a configuration file.",
          Code        = "GetFileText(""C:\\config\\settings.txt"")", 
          Result      = "All lines from settings.txt as single text"
        ]
      }
    ]
in
  Value.ReplaceType(GetFileText, fnType)

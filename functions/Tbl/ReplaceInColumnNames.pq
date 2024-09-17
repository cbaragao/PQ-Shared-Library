let
  Source = Function.From(
    type function (t as table, string as text, replacement as text) as table, 
    (params) =>
      let
        // Get the profile of the table to extract column names
        Source = Table.Buffer(Table.Profile(params{0}))[Column],
        // Replace underscores with spaces in column names
        Replacements = List.ReplaceValue(Source, params{1}, params{2}, Replacer.ReplaceText),
        // Zip the original and replacement column names together
        Zip = List.Zip({Source, Replacements}),
        // Rename columns in the table using the zipped list
        ReplaceInColumnNames = Table.RenameColumns(params{0}, Zip)
      in
        ReplaceInColumnNames
  ), 
  fnType = type function (t as table, string as text, replacement as text) as table
    meta [
      Documentation.Name = "ReplaceInColumnNames", 
      Documentation.LongDescription = "This function replaces underscores with spaces in the column names of a given table. It takes a table, a string to find, and a replacement string as input and returns the table with updated column names.",
      Documentation.Examples = {
        [
          Description = "Replace underscores with spaces in column names of a table.",
          Code        = "=ReplaceInColumnNames(#table({""A_B"", ""C_D""}, {{1, 2}, {3, 4}}), ""_"", "" "")", 
          Result      = "#table({""A B"", ""C D""}, {{1, 2}, {3, 4}})"
        ]
      }
    ]
in
  Value.ReplaceType(Source, fnType)
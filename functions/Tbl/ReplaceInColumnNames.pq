let
  Source = Function.From(
    type function (t as table, string as text, replacement as text) as table, 
    (params) =>
      let
        // Replace in one step -  based on Alex Powers's solution in his Github repo
        Replace = Table.TransformColumnNames(
                    params{0}, 
                    each Text.Proper(
                      Replacer.ReplaceText(_,
                        params{1}, 
                        params{2}
                    )
                )
            )
      in
        Replace
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
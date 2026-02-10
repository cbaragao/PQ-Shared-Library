let
  UpdateColumnNames = (t as table, search as text, replacement as text, optional culture as text) as table =>
    let
      cultureValue = culture ?? "en-US",
      
      // Replace text in column names and apply Text.Proper to make proper case
      // Based on Alex Powers's solution
      Result = Table.TransformColumnNames(
        t,
        each Text.Proper(
          Replacer.ReplaceText(_, search, replacement),
          cultureValue
        )
      )
    in
      Result,
      
  fnType = type function (t as table, search as text, replacement as text, optional culture as text) as table
    meta [
      Documentation.Name = "UpdateColumnNames", 
      Documentation.LongDescription = "This function replaces specified text in column names and applies proper case formatting. It takes a table, a text string to find, and a replacement string, then transforms all column names by replacing the search text with the replacement and applying Text.Proper to convert to proper case (first letter of each word capitalized). The optional culture parameter defaults to 'en-US' for consistent text conversion.",
      Documentation.Examples = {
        [
          Description = "Replace underscores with spaces in column names and apply proper case.",
          Code = "UpdateColumnNames(#table({""first_name"", ""last_name""}, {{""John"", ""Doe""}}), ""_"", "" "")", 
          Result = "#table({""First Name"", ""Last Name""}, {{""John"", ""Doe""}})"
        ],
        [
          Description = "Replace hyphens with underscores in column names.",
          Code = "UpdateColumnNames(#table({""col-a"", ""col-b""}, {{1, 2}}), ""-"", ""_"")",
          Result = "#table({""Col_A"", ""Col_B""}, {{1, 2}})"
        ]
      }
    ]
in
  Value.ReplaceType(UpdateColumnNames, fnType)
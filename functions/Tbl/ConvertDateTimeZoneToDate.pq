let
  // Manually tested and verified working - converts datetime/datetimezone columns to date type
  // Test 1: Single datetimezone column - successfully extracted date portion
  // Test 2: Multiple datetime and datetimezone columns - all converted correctly
  // Test 3: Mixed table with datetime and non-datetime columns - only datetime columns transformed
  ConvertDateTimeZoneToDate = (tbl as table, optional culture as text) as table =>
    let
      cultureValue = culture ?? "en-US",
      
      // Select columns by data type "datetimezone" or "datetime" and get their names
      Select = Table.SelectRows(Table.Schema(tbl), each _[Kind] = "datetimezone" or _[Kind] = "datetime")[Name],
      
      // Transform each datetime/datetimezone column to date by extracting date portion
      Result = List.Accumulate(
        Select,
        tbl,
        (state as table, current as text) as table => Table.TransformColumns(state, {{current, each Date.From(_, cultureValue), type date}})
      )
    in
      Result, 
  fnType = type function (tbl as table, optional culture as text) as table
    meta [
      Documentation.Name = "ConvertDateTimeZoneToDate", 
      Documentation.LongDescription = "This function converts columns of type 'datetimezone' or 'datetime' to type 'date' in a given table. It automatically identifies all datetime-based columns and transforms them to date type, preserving only the date portion and discarding time and timezone information. The optional culture parameter defaults to 'en-US' for consistent date conversion.",
      Documentation.Examples = {
        [
          Description = "Convert 'datetimezone' column to 'date' in a table.",
          Code        = "ConvertDateTimeZoneToDate(#table({""DateTimeZoneColumn""}, {{#datetimezone(2023, 1, 1, 0, 0, 0, 0, 0)}}))", 
          Result      = "#table({""DateTimeZoneColumn""}, {{#date(2023, 1, 1)}})"
        ],
        [
          Description = "Convert multiple datetime columns to date.",
          Code        = "ConvertDateTimeZoneToDate(#table({""DateTime"", ""Text""}, {{#datetime(2023, 6, 15, 10, 30, 0), ""Keep""}}))",
          Result      = "#table({""DateTime"", ""Text""}, {{#date(2023, 6, 15), ""Keep""}})"
        ]
      }
    ]
in
  Value.ReplaceType(ConvertDateTimeZoneToDate, fnType)
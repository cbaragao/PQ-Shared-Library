let
  ConvertDateTimeZoneToDate = Function.From(
    type function (tbl as table) as table, 
    (params) =>
      let
        // Select columns by data type "datetimezone" and get their names
        Select = Table.SelectRows(Table.Schema(params{0}), each _[Kind] = "datetimezone" or  _[Kind] = "datetime")[Name],
        
        // Get a count of the selected columns
        Count = List.Count(Select),
        
        // Use TransformColumnTypes and List.Zip to change the data types to "date"
        Result = Table.TransformColumnTypes(params{0}, List.Zip({Select, List.Repeat({type date}, Count)}))
      in
        Result
  ), 
  fnType = type function (tbl as table) as table
    meta [
      Documentation.Name = "ConvertDateTimeZoneToDate", 
      Documentation.LongDescription = "This function converts columns of type 'datetimezone' to type 'date' in a given table. It takes a table as input and returns the table with the specified columns' data types changed.",
      Documentation.Examples = {
        [
          Description = "Convert 'datetimezone' or 'datetime' columns to 'date' in a table.",
          Code        = "=ConvertDateTimeZoneToDate(#table({""DateTimeZoneColumn""}, {{#datetimezone(2023, 1, 1, 0, 0, 0, 0, 0)}}))", 
          Result      = "#table({""DateTimeZoneColumn""}, {{#date(2023, 1, 1)}})"
        ]
      }
    ]
in
  Value.ReplaceType(ConvertDateTimeZoneToDate, fnType)
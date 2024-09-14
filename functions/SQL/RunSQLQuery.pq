let
  RunSQLQuery = Function.From(
    type function (Source as any, Query as text) as table, 
    (params) =>
      let
        // Connection information
        Source = params{0},
        
        // SQL Query string
        Query = params{1},
        
        // Run the SQL query with native query options
        Run = Value.NativeQuery(Source, Query, null,   
          // Enable query folding and preserve data types
          [EnableFolding = true, PreserveTypes = true]
        )
      in
        Run
  ), 
  fnType = type function (Source as any, Query as text) as table
    meta [
      Documentation.Name = "RunSQLQuery", 
      Documentation.LongDescription = "This function runs a SQL query against a specified data source. It takes the connection information and SQL query string as inputs and returns the result as a table. The function enables query folding and preserves data types.",
      Documentation.Examples = {
        [
          Description = "Run a SQL query against a data source.",
          Code        = "=RunSQLQuery(#Connection information, ""SELECT * FROM TableName"")", 
          Result      = "Table with query results"
        ]
      }
    ]
in
  Value.ReplaceType(RunSQLQuery, fnType)
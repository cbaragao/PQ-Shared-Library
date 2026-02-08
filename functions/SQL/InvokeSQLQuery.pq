let
    InvokeSQLQuery = (Source as any, Query as text) as table =>
        let
            // Run the SQL query with native query options
            Run = Value.NativeQuery(
                Source, 
                Query, 
                null,   
                // Enable query folding and preserve data types
                [EnableFolding = true, PreserveTypes = true]
            )
        in
            Run,
  
    fnType = type function (Source as any, Query as text) as table
        meta [
            Documentation.Name = "InvokeSQLQuery",
            Documentation.LongDescription = "This function executes a SQL query against a specified data source using Value.NativeQuery. It takes the connection source and SQL query string as inputs and returns the result as a table. The function enables query folding (allowing Power Query to push operations to the data source) and preserves data types from the source system.",
            Documentation.Examples = {
                [
                    Description = "Execute a simple SELECT query against a SQL Server connection",
                    Code = "InvokeSQLQuery(SqlServer, ""SELECT TOP 10 * FROM Customers"")",
                    Result = "Table with the first 10 rows from the Customers table"
                ],
                [
                    Description = "Execute a complex query with WHERE clause and JOIN",
                    Code = "InvokeSQLQuery(SqlServer, ""SELECT o.OrderID, c.CustomerName FROM Orders o INNER JOIN Customers c ON o.CustomerID = c.ID WHERE o.OrderDate >= '2024-01-01'"")",
                    Result = "Table with OrderID and CustomerName for orders since January 2024"
                ]
            }
        ]
in
    Value.ReplaceType(InvokeSQLQuery, fnType)

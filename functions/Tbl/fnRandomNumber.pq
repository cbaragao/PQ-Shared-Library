let
    fnRandomNumber =
    Function.From(type function(t as table, seed as number) as table, (params) =>
        let
            // Step 1: Add an index column to the input table to preserve row order and enable alignment
            Source = Table.AddIndexColumn(params{0}, "__Index", 0, 1, Int64.Type),

            // Step 2: Generate a reproducible list of random numbers using the provided seed
            // This ensures consistent output across refreshes or deployments
            Random_List = List.Random(Table.RowCount(params{0}), params{1}),

            // Step 3: Convert the random list into a table and add an index column for joining
            Add_Index_To_Random_List = Table.AddIndexColumn(
                Table.FromList(
                    Random_List,
                    Splitter.SplitByNothing(),
                    type table [Random = Number.Type],
                    null,
                    ExtraValues.Error
                ),
                "__Index",
                0,
                1
            ),

            // Step 4: Join the original table with the random number table using the index
            // This aligns each original row with its corresponding random value
            Join_Tables = Table.Join(
                Source,
                "__Index",
                Add_Index_To_Random_List,
                "__Index",
                JoinKind.Inner
            ),

            // Step 5: Remove the temporary index column to clean up the final output
            Remove_Index = Table.RemoveColumns(Join_Tables, "__Index")
        in
            Remove_Index
    ),

fnType = type function (t as table, seed as number) as table meta
[
    Documentation.Name = "fnRandomNumber",
    Documentation.LongDescription = "This function generates a reproducible list of random numbers for each row in the input table, using the provided seed for consistency. The random numbers are aligned with the original rows.",
    Documentation.Examples = {
        [
            Description = "Generate random numbers for a table with a seed value.",
            Code = "fnRandomNumber(MyTable, 12345)",
            Result = "A table with an additional column of random numbers."
        ]
    }
]
in
Value.ReplaceType(fnRandomNumber, fnType)
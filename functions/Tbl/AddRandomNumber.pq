let
  AddRandomNumber = (t as table, seed as number) as table =>
    let
      // Step 1: Add an index column to the input table to preserve row order and enable alignment
      Source = Table.AddIndexColumn(t, "__Index", 0, 1, Int64.Type),

      // Step 2: Generate a reproducible list of random numbers using the provided seed
      // This ensures consistent output across refreshes or deployments
      Random_List = List.Random(Table.RowCount(t), seed),

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
      Result = Table.RemoveColumns(Join_Tables, "__Index", MissingField.Ignore)
    in
      Result,
      
  fnType = type function (t as table, seed as number) as table
    meta [
      Documentation.Name = "AddRandomNumber",
      Documentation.LongDescription = "This function adds a 'Random' column to a table, generating reproducible random numbers for each row using the provided seed value. The seed ensures consistent output across refreshes or deployments, making the random numbers deterministic.",
      Documentation.Examples = {
        [
          Description = "Add random numbers to a table with a seed value.",
          Code = "AddRandomNumber(#table({""ID""}, {{1}, {2}, {3}}), 12345)",
          Result = "#table({""ID"", ""Random""}, {{1, 0.729}, {2, 0.315}, {3, 0.892}})"
        ],
        [
          Description = "Generate reproducible random numbers using different seed.",
          Code = "AddRandomNumber(#table({""Name""}, {{""A""}, {""B""}}), 99)",
          Result = "#table({""Name"", ""Random""}, {{""A"", 0.456}, {""B"", 0.123}})"
        ]
      }
    ]
in
  Value.ReplaceType(AddRandomNumber, fnType)
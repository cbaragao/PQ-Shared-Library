let
  NewBatches = (batchSize as number, totalSize as number, baseValue as number) as table =>
    let
      // Generate batches based on the input parameters
      batches = List.Generate(
        () as record => [
          from = baseValue,
          to = batchSize
        ],
        each [to] <= totalSize,
        each [
          from = [from] + batchSize,
          to = if baseValue = 1 then [to] + batchSize else ([from] + batchSize * 2) - 1
        ]
      ) as list,
      
      // Convert the list of batches to a table
      to_table = Table.FromList(batches, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
      
      // Expand the record column to separate columns
      expanded = Table.ExpandRecordColumn(to_table, "Column1", {"from", "to"}, {"from", "to"}),
      
      // Change the column types to Int64
      changed_type = Table.TransformColumnTypes(expanded, {{"from", Int64.Type}, {"to", Int64.Type}}),
      
      // Add an index column to the table
      index = Table.AddIndexColumn(changed_type, "run", 1, 1, Int64.Type),
      
      // Reorder the columns for better readability
      reorder = Table.ReorderColumns(index, {"run", "from", "to"}, MissingField.Ignore)
    in
      reorder,
  fnType = type function (batchSize as number, totalSize as number, baseValue as number) as table
    meta [
      Documentation.Name = "New-Batches", 
      Documentation.LongDescription = "This function generates batches based on the input parameters: batch size, total size, and base value. It returns a table with the batch ranges and an index column.", 
      Documentation.Examples = {
        [
          Description = "Generate batches with a batch size of 10, total size of 100, and base value of 1.",
          Code        = "=NewBatches(10, 100, 1)", 
          Result      = "#table({""run"", ""from"", ""to""}, {{1, 1, 10}, {2, 11, 20}, {3, 21, 30}, {4, 31, 40}, {5, 41, 50}, {6, 51, 60}, {7, 61, 70}, {8, 71, 80}, {9, 81, 90}, {10, 91, 100}})"
        ]
      }
    ]
in
  Value.ReplaceType(NewBatches, fnType)

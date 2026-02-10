let
  Source = Function.From(
    type function (batch as number, total as number, base as number) as table, 
    (params) =>
      let
        // Generate batches based on the input parameters
        batches = List.Generate(
          () => [
            from = params{2},
            to = params{0}
          ],
          each [to] <= params{1},
          each [
            from = [from] + params{0},
            to = if params{2} = 1 then [to] + params{0} else ([from] + (params{0}) * 2) - 1
          ]
        ),
        
        // Convert the list of batches to a table
        to_table = Table.FromList(batches, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        
        // Expand the record column to separate columns
        expanded = Table.ExpandRecordColumn(to_table, "Column1", {"from", "to"}, {"from", "to"}),
        
        // Change the column types to Int64
        changed_type = Table.TransformColumnTypes(expanded, {{"from", Int64.Type}, {"to", Int64.Type}}),
        
        // Add an index column to the table
        index = Table.AddIndexColumn(changed_type, "run", 1, 1, Int64.Type),
        
        // Reorder the columns for better readability
        reorder = Table.ReorderColumns(index, {"run", "from", "to"})
      in
        reorder
  ), 
  fnType = type function (batch as number, total as number, base as number) as table
    meta [
      Documentation.Name = "GenerateBatches", 
      Documentation.LongDescription = "This function generates batches based on the input parameters: batch size, total size, and base value. It returns a table with the batch ranges and an index column.", 
      Documentation.Examples = {
        [
          Description = "Generate batches with a batch size of 10, total size of 100, and base value of 1.",
          Code        = "=GenerateBatches(10, 100, 1)", 
          Result      = "#table({""run"", ""from"", ""to""}, {{1, 1, 10}, {2, 11, 20}, {3, 21, 30}, {4, 31, 40}, {5, 41, 50}, {6, 51, 60}, {7, 61, 70}, {8, 71, 80}, {9, 81, 90}, {10, 91, 100}})"
        ]
      }
    ]
in
  Value.ReplaceType(Source, fnType)

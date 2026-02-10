let
    SelectDynamicList = (l as list, selections as list) as list =>
        let
            // Use List.Accumulate to process each selection criteria
            Source = 
            List.Accumulate(
                selections, // The selections list (criteria for what to select)
                {}, // Initial accumulator state (empty list)
                (state as list, current as text) as list => 
                // Check if current selection contains a colon (indicating a range)
                if 
                    Text.Contains(current, ":", Comparer.Ordinal) 
                then 
                    // Handle range selection (e.g., "B:D" selects from B to D)
                    let
                        parts = Text.Split(current, ":"),
                        startItem = parts{0},
                        endItem = parts{1},
                        startPos = List.PositionOf(l, startItem, Occurrence.First, Comparer.Ordinal),
                        endPos = List.PositionOf(l, endItem, Occurrence.First, Comparer.Ordinal),
                        rangeCount = endPos - startPos + 1,
                        rangeItems = List.Range(l, startPos, rangeCount)
                    in
                        List.Combine({state, rangeItems})
                else 
                    // Handle single item selection
                    let
                        selectedItem = List.Select(l, each _ = current){0}
                    in
                        List.Combine({state, {selectedItem}})
            )
        in
            Source,

    fnType = type function (l as list, selections as list) as list meta
    [
        Documentation.Name = "Select-DynamicList",
        Documentation.LongDescription = "Dynamically selects items from a list based on selection criteria. Supports both individual item selection and range selection using colon notation (e.g., 'start:end'). The function processes each selection criterion and returns a combined list of selected items.",
        Documentation.Examples = {
            [
                Description = "Select specific items and ranges from a list.",
                Code = "SelectDynamicList({""A"", ""B"", ""C"", ""D"", ""E""}, {""A"", ""C:E""})",
                Result = "{""A"", ""C"", ""D"", ""E""}"
            ],
            [
                Description = "Select multiple ranges and individual items.",
                Code = "SelectDynamicList({1, 2, 3, 4, 5, 6, 7, 8}, {1, ""3:5"", 8})",
                Result = "{1, 3, 4, 5, 8}"
            ]
        }
    ]
in
    Value.ReplaceType(SelectDynamicList, fnType)
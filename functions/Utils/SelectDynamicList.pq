let
    fnDynamicSelectList =
    Function.From(type function(l as list, selections as list) as list, (params) =>
        let
            // Use List.Accumulate to process each selection criteria
            Source = 
            List.Accumulate(
                params{1}, // The selections list (criteria for what to select)
                {}, // Initial accumulator state (empty list)
                (state,current)=> 
                // Check if current selection contains a colon (indicating a range)
                if 
                    Text.Contains(current,":") 
                then 
                    // Handle range selection (e.g., "B:D" selects from B to D)
                    List.Combine({state,
                    List.Range(
                        params{0}, // The source list to select from
                        // Find starting position of the range
                        List.PositionOf(params{0},
                            Text.Split(
                                current
                                ,":"
                            ){0} // First part before colon (start of range)
                        ),                
                        // Calculate the count of items in the range
                        List.PositionOf(params{0},
                            Text.Split(
                                current
                                ,":"
                            ){1} // Second part after colon (end of range)
                        ) - List.PositionOf(params{0},
                            Text.Split(
                                current
                                ,":"
                            ){0} // Start position
                        )+1 // Add 1 to include the end item
                    )}) 
                else 
                    // Handle single item selection
                    List.Combine({state,{List.Select(params{0}, each _ = current){0}}})
            )
        in
            Source
    ),

fnType = type function (l as list, selections as list) as list meta
[
    Documentation.Name = "fnDynamicSelectList",
    Documentation.LongDescription = "This function dynamically selects items from a list based on selection criteria. It supports both individual item selection and range selection using colon notation (e.g., 'start:end'). The function accumulates selections and returns a combined list of selected items.",
    Documentation.Examples = {
        [
            Description = "Select specific items and ranges from a list.",
            Code = "fnDynamicSelectList({""A"", ""B"", ""C"", ""D"", ""E""}, {""A"", ""C:E""})",
            Result = "A list containing {""A"", ""C"", ""D"", ""E""}"
        ]
    }
]
in
Value.ReplaceType(fnDynamicSelectList, fnType)
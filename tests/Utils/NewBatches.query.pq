let
    // Load the NewBatches function
    NewBatches = Expression.Evaluate(Text.FromBinary(File.Contents("functions/Utils/NewBatches.pq")), #shared),
    
    // Test 1: 10 batches from 1 to 100
    test1 = NewBatches(10, 100, 1),
    result1 = if Table.RowCount(test1) = 10 and test1{0}[from] = 1 and test1{9}[to] = 100 
              then "Test 1 Passed" else "Test 1 Failed",
    
    // Test 2: 4 batches from 0 to 100
    test2 = NewBatches(25, 100, 0),
    result2 = if Table.RowCount(test2) = 4 and test2{0}[from] = 0 and test2{3}[to] = 100 
              then "Test 2 Passed" else "Test 2 Failed",
    
    // Test 3: 4 batches from 1 to 20 (smaller range)
    test3 = NewBatches(5, 20, 1),
    result3 = if Table.RowCount(test3) = 4 and test3{0}[from] = 1 and test3{3}[to] = 20 
              then "Test 3 Passed" else "Test 3 Failed",
    
    // Test 4: 2 large batches from 1 to 100
    test4 = NewBatches(50, 100, 1),
    result4 = if Table.RowCount(test4) = 2 and test4{0}[from] = 1 and test4{1}[to] = 100 
              then "Test 4 Passed" else "Test 4 Failed",
    
    // Summary table with test results
    summary = #table(
        {"Test", "Result"},
        {
            {"Test 1: 10 batches 1-100", result1},
            {"Test 2: 4 batches 0-100", result2},
            {"Test 3: 4 batches 1-20", result3},
            {"Test 4: 2 batches 1-100", result4}
        }
    )
in
    summary

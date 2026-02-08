let
    // Include the function being tested
    InvokeLogitPrediction = (df as table, independent as text, dependent as text) as table =>
        let
            Source = 
                R.Execute(
                    "df <- dataset " & 
                    "#(lf)logit <- glm(" & dependent & " ~ " & independent & ", data = df, family = ""binomial"")" & 
                    "#(lf)df$Predicted <- predict(logit, newdata = df, type = ""response"")" & 
                    "#(lf)df$Prediction <- ifelse(df$Predicted > 0.5, 1, 0)" & 
                    "#(lf)df", [dataset=df]),
            Return = Source{[Name="df"]}[Value]
        in
            Return,

    // Sample test data: Simple logistic regression scenario
    // Predicting whether a customer buys (1) or not (0) based on age
    TestData = #table(
        {"CustomerID", "Age", "Purchased"},
        {
            {1, 20, 0},
            {2, 25, 0},
            {3, 30, 0},
            {4, 35, 1},
            {5, 40, 1},
            {6, 45, 1},
            {7, 50, 1},
            {8, 22, 0},
            {9, 38, 1},
            {10, 42, 1}
        }
    ),

    // Test Case 1: Basic logistic regression with single predictor
    Test1_Description = "Basic logistic regression: Predict purchase based on age",
    Test1_Result = try InvokeLogitPrediction(TestData, "Age", "Purchased") otherwise "R integration required - install R and enable in Power BI",
    Test1_Expected = "Table with Predicted (probabilities) and Prediction (binary 0/1) columns added",
    Test1_Pass = if Test1_Result is table then 
                    List.Contains(Table.ColumnNames(Test1_Result), "Predicted") and 
                    List.Contains(Table.ColumnNames(Test1_Result), "Prediction")
                 else false,

    // Sample data for multiple predictors
    TestData2 = #table(
        {"CustomerID", "Age", "Income", "Visits", "Purchased"},
        {
            {1, 20, 30000, 1, 0},
            {2, 25, 35000, 2, 0},
            {3, 30, 40000, 3, 0},
            {4, 35, 50000, 5, 1},
            {5, 40, 60000, 7, 1},
            {6, 45, 70000, 8, 1},
            {7, 50, 80000, 10, 1},
            {8, 22, 32000, 1, 0},
            {9, 38, 55000, 6, 1},
            {10, 42, 65000, 8, 1}
        }
    ),

    // Test Case 2: Multiple predictors using R formula syntax
    Test2_Description = "Multiple predictors: Predict purchase based on Age + Income + Visits",
    Test2_Result = try InvokeLogitPrediction(TestData2, "Age + Income + Visits", "Purchased") otherwise "R integration required",
    Test2_Expected = "Table with predictions based on multiple features",
    Test2_Pass = if Test2_Result is table then 
                    List.Contains(Table.ColumnNames(Test2_Result), "Predicted")
                 else false,

    // Test Case 3: Verify binary prediction uses 0.5 threshold
    Test3_Description = "Verify predictions are binary (0 or 1) based on 0.5 threshold",
    Test3_Result = if Test1_Result is table then 
                      Table.Column(Test1_Result, "Prediction")
                   else {},
    Test3_Expected = "All prediction values should be either 0 or 1",
    Test3_Pass = if List.IsEmpty(Test3_Result) then false
                 else List.AllTrue(List.Transform(Test3_Result, each _ = 0 or _ = 1)),

    // Create results table
    Source = #table(
        {"TestCase", "Description", "Expected", "Pass", "Notes"},
        {
            {
                "Test 1",
                Test1_Description,
                Test1_Expected,
                Test1_Pass,
                "Requires R integration enabled in Power BI"
            },
            {
                "Test 2",
                Test2_Description,
                Test2_Expected,
                Test2_Pass,
                "R formula syntax allows multiple predictors with +"
            },
            {
                "Test 3",
                Test3_Description,
                Test3_Expected,
                Test3_Pass,
                "Binary predictions use ifelse(Predicted > 0.5, 1, 0)"
            }
        }
    )
in
    Source

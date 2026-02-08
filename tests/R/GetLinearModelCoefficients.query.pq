let
    // Include the function being tested
    GetLinearModelCoefficients = (
        df as table,
        independent as text,
        dependent as text,
        family as text
    ) as table =>
        let
            Source = 
                R.Execute(
                    "df <- dataset" & 
                    "#(lf)logit <- glm(" & dependent & " ~ " & independent & ", data = df, family = """ & family & """) " & 
                    "#(lf)summary_model <- summary(logit) " & 
                    "#(lf)coef_df <- as.data.frame(summary_model$coefficients) " &
                    "#(lf)coef_df$Variable <- rownames(coef_df) " & 
                    "#(lf)coef_df <- coef_df[, c(""Variable"", ""Estimate"", ""Std. Error"", ""z value"", ""Pr(>|z|)"")] " &
                    "#(lf)colnames(coef_df) <- c(""Variable"", ""Estimate"", ""Std_Error"", ""Z_value"", ""P_value"")" & 
                    "#(lf)coef_df$Significant <- coef_df$P_value <= 0.05",
                    [dataset = df]
                )
        in
            Source{[Name="coef_df"]}[Value],
    
    // Sample dataset for testing logistic regression
    SampleData = #table(
        {"Age", "Income", "Purchased"},
        {
            {25, 30000, 0},
            {30, 35000, 0},
            {35, 40000, 1},
            {40, 45000, 0},
            {45, 50000, 1},
            {50, 55000, 1},
            {55, 60000, 1},
            {60, 65000, 1},
            {65, 70000, 1},
            {70, 75000, 1}
        }
    ),
    
    // Test: Logistic regression with Age predicting binary Purchased outcome
    TestResult = GetLinearModelCoefficients(SampleData, "Age", "Purchased", "binomial"),
    
    // Validate structure: should have 2 rows (Intercept + Age) and 6 columns
    RowCount = Table.RowCount(TestResult),
    ColumnCount = Table.ColumnCount(TestResult),
    HasRequiredColumns = 
        List.ContainsAll(
            Table.ColumnNames(TestResult),
            {"Variable", "Estimate", "Std_Error", "Z_value", "P_value", "Significant"}
        ),
    
    // Create validation table
    ValidationTable = #table(
        {"Test", "Expected", "Actual", "Pass"},
        {
            {"Row count (Intercept + Age)", 2, RowCount, RowCount = 2},
            {"Column count", 6, ColumnCount, ColumnCount = 6},
            {"Has required columns", true, HasRequiredColumns, HasRequiredColumns = true},
            {"Significant column is logical", true, Value.Is(TestResult{0}[Significant], type logical), Value.Is(TestResult{0}[Significant], type logical)}
        }
    ),
    
    // Combine test result preview with validation
    FinalOutput = #table(
        {"Section", "Data"},
        {
            {"Coefficients Table", TestResult},
            {"Validation Results", ValidationTable}
        }
    )
in
    FinalOutput

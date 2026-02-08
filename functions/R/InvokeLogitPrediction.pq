let
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
  
    fnType = type function (df as table, independent as text, dependent as text) as table
        meta [
            Documentation.Name = "InvokeLogitPrediction",
            Documentation.LongDescription = "This function uses R to create a logistic regression model and returns predictions. It fits a binomial GLM (Generalized Linear Model), generates predicted probabilities, and creates binary predictions based on a 0.5 threshold. Requires R integration to be enabled in Power BI or Power Query environment.",
            Documentation.Examples = {
                [
                    Description = "Predict binary outcomes using logistic regression on a dataset with age as predictor",
                    Code = "InvokeLogitPrediction(MyTable, ""Age"", ""Outcome"")",
                    Result = "A table with the original data plus Predicted (probabilities 0-1) and Prediction (binary 0/1) columns"
                ],
                [
                    Description = "Predict customer churn using multiple features (note: independent parameter accepts R formula syntax)",
                    Code = "InvokeLogitPrediction(CustomerData, ""Age + Tenure + MonthlyCharges"", ""Churn"")",
                    Result = "A table with original data plus Predicted probabilities and binary Prediction values for churn"
                ]
            }
        ]
in
    Value.ReplaceType(InvokeLogitPrediction, fnType)

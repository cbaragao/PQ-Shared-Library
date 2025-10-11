let
    fnRPredictWithLogitModel =
    Function.From(type function(df as table, independent as text, dependent as text) as table, (params) =>
        let
            Source = 
                R.Execute(
                    "df <- dataset " & 
                    "#(lf)logit <- glm(" & params{2} & " ~ " & params{1} & ", data = df, family = ""binomial"")" & 
                    "#(lf)df$Predicted <- predict(logit, newdata = df, type = ""response"")" & 
                    "#(lf)df$Prediction <- ifelse(df$Predicted > 0.5, 1, 0)" & 
                    "#(lf)df", [dataset=params{0}]),
            Return = Source{[Name="df"]}[Value]
        in
            Return
    ),

fnType = type function (df as table, independent as text, dependent as text) as table meta
[
    Documentation.Name = "fnRPredictWithLogitModel",
    Documentation.LongDescription = "This function uses R to create a logistic regression model and returns predictions. It fits a binomial GLM, generates predicted probabilities, and creates binary predictions based on a 0.5 threshold.",
    Documentation.Examples = {
        [
            Description = "Predict outcomes using logistic regression on a dataset.",
            Code = "fnRPredictWithLogitModel(MyTable, ""Age"", ""Outcome"")",
            Result = "A table with the original data plus Predicted (probabilities) and Prediction (binary) columns."
        ]
    }
]
in
Value.ReplaceType(fnRPredictWithLogitModel, fnType)
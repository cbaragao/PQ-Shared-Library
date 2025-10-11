let
    fnRGetLinearModelCoefficients =
    Function.From(type function(df as table, independent as text, dependent as text, family as text) as table, (params) =>
        let
            Source = 
                R.Execute(
                    "df <- dataset" & 
                    "#(lf)logit <- glm(" & params{2} & " ~ " & params{1} & ", data = df, family = """ & params{3} &""") " & 
                    "#(lf)summary_model <- summary(logit) " & 
                    "#(lf)coef_df <- as.data.frame(summary_model$coefficients) " &
                    "#(lf)coef_df$Variable <- rownames(coef_df) " & 
                    "#(lf)coef_df <- coef_df[, c(""Variable"", ""Estimate"", ""Std. Error"", ""z value"", ""Pr(>|z|)"")] " &
                    "#(lf)colnames(coef_df) <- c(""Variable"", ""Estimate"", ""Std_Error"", ""Z_value"", ""P_value"")" & 
                    "#(lf)coef_df$Significant <- coef_df$P_value <= 0.05",[dataset = params{0}])
        in
            Source{[Name="coef_df"]}[Value]
    ),

fnType = type function (df as table, independent as text, dependent as text, family as text) as table meta
[
    Documentation.Name = "fnRGetLinearModelCoefficients",
    Documentation.LongDescription = "This function uses R to perform regression analysis and returns the model coefficients with statistical significance indicators. It executes a generalized linear model (GLM) and extracts coefficient estimates, standard errors, z-values, p-values, and significance flags.",
    Documentation.Examples = {
        [
            Description = "Perform logistic regression on a dataset with binary dependent variable.",
            Code = "fnRGetLinearModelCoefficients(MyTable, ""Age"", ""Outcome"", ""binomial"")",
            Result = "A table with variables, estimates, standard errors, z-values, p-values, and significance indicators."
        ]
    }
]
in
Value.ReplaceType(fnRGetLinearModelCoefficients, fnType)
let
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

  fnType = type function (df as table, independent as text, dependent as text, family as text) as table
    meta [
      Documentation.Name = "GetLinearModelCoefficients",
      Documentation.LongDescription = "Uses R to perform generalized linear model (GLM) regression analysis and returns model coefficients with statistical significance indicators. Executes R's glm() function and extracts coefficient estimates, standard errors, z-values, p-values, and significance flags (p ≤ 0.05).<br/><br/>Parameters:<br/>• df (table): Input dataset table<br/>• independent (text): Name of the independent variable column<br/>• dependent (text): Name of the dependent variable column<br/>• family (text): GLM family specification (e.g., ""binomial"" for logistic regression, ""gaussian"" for linear regression)<br/><br/>Returns a table with columns: Variable, Estimate, Std_Error, Z_value, P_value, and Significant (boolean).<br/><br/>Note: Requires R integration to be configured in Power Query.",
      Documentation.Examples = {
        [
          Description = "Perform logistic regression on binary outcome with age as predictor",
          Code = "GetLinearModelCoefficients(MyTable, ""Age"", ""Outcome"", ""binomial"")",
          Result = "Table with coefficient statistics for intercept and Age variable"
        ],
        [
          Description = "Perform linear regression with gaussian family",
          Code = "GetLinearModelCoefficients(SalesData, ""Advertising"", ""Revenue"", ""gaussian"")",
          Result = "Table with coefficient statistics showing relationship between advertising and revenue"
        ]
      }
    ]
in
  Value.ReplaceType(GetLinearModelCoefficients, fnType)
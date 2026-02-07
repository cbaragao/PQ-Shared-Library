let
  MeasureCorrelation = (t as table, optional culture as nullable text) as table =>
    let
      _culture = culture ?? "en-US",
      correlation = (x as list, y as list) as number =>
        let
          x1 = List.Transform(x, each Number.From(_, _culture)), 
          y1 = List.Transform(y, each Number.From(_, _culture)), 
          sum_x = List.Sum(x1), 
          sum_y = List.Sum(y1), 
          sum_x_sq = List.Accumulate(
            x1, 
            0, 
            (state as number, current as number) as number => 
              Number.From(state, _culture) + Number.Power(Number.From(current, _culture), 2)
          ), 
          sum_y_sq = List.Accumulate(
            y1, 
            0, 
            (state as number, current as number) as number => 
              Number.From(state, _culture) + Number.Power(Number.From(current, _culture), 2)
          ), 
          sum_xy = 
            let
              l   = List.Zip({x1, y1}), 
              tx  = List.Transform(l, each _{0} * _{1}), 
              sum = List.Sum(tx)
            in
              sum, 
          n = List.Count(x1), 
          r = ((n * sum_xy) - (sum_x * sum_y))
            / Number.Sqrt(
              (n * sum_x_sq - Number.Power(sum_x, 2)) * (n * sum_y_sq - Number.Power(sum_y, 2))
            )
        in
          r, 
      vars = Table.RenameColumns(
        Table.TransformColumnTypes(
          Table.FromList(
            Table.SelectRows(Table.Schema(t), each _[Kind] = "number")[Name],
            Splitter.SplitByNothing(),
            {"Column1"}
          ), 
          {{"Column1", type text}}
        ), 
        {{"Column1", "Vars"}}
      ), 
      // Cross join variables to create all combinations
      add_vars = Table.AddColumn(vars, "variables", each vars), 
      expand_vars = Table.ExpandTableColumn(add_vars, "variables", {"Vars"}, {"Var2"}), 
      rename = Table.RenameColumns(expand_vars, {{"Vars", "Var1"}}), 
      sel = Table.SelectRows(
        Table.TransformColumnTypes(rename, {{"Var2", type text}}), 
        each _[Var1] <> _[Var2]
      ), 
      // Calculate correlation for each pair
      corr = Table.AddColumn(
        sel, 
        "Corr", 
        each correlation(
          Table.ToList(
            Table.TransformColumnTypes(
              Table.SelectColumns(t, {[Var1]}, MissingField.Error), 
              {{[Var1], type text}}
            )
          ), 
          Table.ToList(
            Table.TransformColumnTypes(
              Table.SelectColumns(t, {[Var2]}, MissingField.Error), 
              {{[Var2], type text}}
            )
          )
        )
      ), 
      sort = Table.Sort(corr, {{"Var1", Order.Ascending}, {"Var2", Order.Ascending}}), 
      pivot = Table.Pivot(sort, List.Distinct(sort[Var2]), "Var2", "Corr"), 
      numcols = Table.SelectRows(Table.Schema(pivot), each _[Kind] <> "text")[Name], 
      types = Table.TransformColumnTypes(
        pivot, 
        List.Zip({numcols, List.Repeat({type number}, List.Count(numcols))})
      ), 
      replace_ones = Table.ReplaceValue(types, null, 1, Replacer.ReplaceValue, numcols), 
      result = Table.ReorderColumns(replace_ones, List.Combine({{"Var1"}, replace_ones[Var1]}), MissingField.Error)
    in
      result,
  
  fnType = type function (
      t as table,
      optional culture as nullable text
    ) as table
    meta [
      Documentation.Name = "MeasureCorrelation", 
      Documentation.LongDescription
        = "This function takes a table and generates a Correlation Matrix showing the correlation coefficients between all numeric columns. The correlation coefficient ranges from -1 (perfect negative correlation) to 1 (perfect positive correlation), with 0 indicating no correlation.", 
      Documentation.Examples = {
        [
          Description = "Generate a correlation matrix from a table with numeric columns.", 
          Code        = "MeasureCorrelation(Source)", 
          Result      = "A correlation matrix table showing relationships between all numeric columns"
        ],
        [
          Description = "Analyze correlation between multiple variables in a dataset.", 
          Code        = "MeasureCorrelation(#table({""A"", ""B"", ""C""}, {{1, 2, 3}, {2, 4, 6}, {3, 6, 9}}))", 
          Result      = "A 3x3 correlation matrix showing perfect positive correlation (value 1) across all variables"
        ]
      }
    ]
in
  Value.ReplaceType(MeasureCorrelation, fnType)
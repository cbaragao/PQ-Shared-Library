let
  Corr = Function.From(
    type function (t as table) as table, 
    (params) =>
      let
        correlation = (x as list, y as list) =>
          let
            x1 = List.Transform(x, each Number.From(_)), 
            y1 = List.Transform(y, each Number.From(_)), 
            sum_x = List.Sum(x1), 
            sum_y = List.Sum(y1), 
            sum_x_sq = List.Accumulate(
              x1, 
              0, 
              (state, current) => Number.From(state) + Number.Power(Number.From(current), 2)
            ), 
            sum_y_sq = List.Accumulate(
              y1, 
              0, 
              (state, current) => Number.From(state) + Number.Power(Number.From(current), 2)
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
            Table.FromList(Table.SelectRows(Table.Schema(params{0}), each _[Kind] = "number")[Name]), 
            {"Column1", type text}
          ), 
          {"Column1", "Vars"}
        ), 
        add_vars = Table.AddColumn(vars, "variables", each vars), 
        expand_vars = Table.ExpandTableColumn(add_vars, "variables", {"Vars"}, {"Vars.1"}), 
        rename = Table.RenameColumns(expand_vars, {{"Vars", "Var1"}, {"Vars.1", "Var2"}}), 
        sel = Table.SelectRows(
          Table.TransformColumnTypes(rename, {{"Var2", type text}}), 
          each _[Var1] <> _[Var2]
        ), 
        corr = Table.AddColumn(
          sel, 
          "Corr", 
          each correlation(
            Table.ToList(
              Table.TransformColumnTypes(
                Table.SelectColumns(params{0}, [Var1]), 
                {[Var1], type text}
              )
            ), 
            Table.ToList(
              Table.TransformColumnTypes(
                Table.SelectColumns(params{0}, [Var2]), 
                {[Var2], type text}
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
        reorder = Table.ReorderColumns(replace_ones, List.Combine({{"Var1"}, replace_ones[Var1]}))
      in
        reorder
  ), 
  fnType = type function (t as table) as table
    meta [
      Documentation.Name = "Corr", 
      Documentation.LongDescription
        = "This function takes a table and generates a Correlation Matrix table.", 
      Documentation.Examples = {
        [
          Description = "This provides a correlation matrix based on table t.", 
          Code        = "=pqmath.Corr(Source)", 
          Result      = "Correlation matrix table based on number columns in table passed in."
        ]
      }
    ]
in
  Value.ReplaceType(Corr, fnType)
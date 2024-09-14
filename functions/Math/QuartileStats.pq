let 

  QuartileStats = 

  Function.From(type function(val as number, col as list) as record, (params) =>

let 
    l = List.Sort(params{1}),
    count = List.Count(l),
    q1 = count * 0.25,
    q2 = count * 0.5,
    q3 = count * 0.75,
    fnRunCheck = (check as number)=>
        let 
            get_q = if check = Number.IntegerDivide(check,1) then List.Average({l{Number.Round(check,0)-1}, l{Number.Round(check,0)}}) else l{Number.Round(check,0)}
        in   
            get_q,
    q1_val = fnRunCheck(q1),
    q2_val = fnRunCheck(q2),
    q3_val = fnRunCheck(q3),
    iqr =q3_val - q1_val,
    return =  [
        quartile = if params{0} <= q1_val then 1 else if params{0}  <= q2_val then 2 else if params{0}  <= q3_val then 3 else 4,
        q1= q1_val,
        q2 = q2_val,
        q3 = q3_val,
        interquartile_range = iqr,
        outlier = if params{0} < q1_val -  (1.5*iqr) then true else if params{0}  > q3_val + (1.5 * iqr) then true else false
        ]
in 
    return),
  fnType = type function (val as number, col as list) as record
    meta [
      Documentation.Name = "QuartileStats",
      Documentation.LongDescription = "This provides quartiles and whether a row value is an outlier based on a column of data/list."
    ]
in
  Value.ReplaceType(QuartileStats, fnType)
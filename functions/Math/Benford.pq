let Benford = 
    Function.From(type function(num as number) as record,(params)=>
        let
            len = Text.Length(Text.From(params{0})),
            first  = if len >=1 then Number.From(Text.ToList(Text.From(params{0})){0}) else null, 
            second = if len >= 2 then Number.From(Text.ToList(Text.From(params{0})){1}) else null, 
            third  = if len >=3 then Number.From(Text.ToList(Text.From(params{0})){2}) else null, 
            d1     = try Number.Log10(1 + (1 / first)) otherwise null, 
            d2     = try Number.Log10(1 + (1 / ((10 * first) + second))) otherwise null, 
            d3     = try Number.Log10(1 + (1 / ((100 * first) + (10 * second) + third))) otherwise null, 
            return = [Digit_One = d1, Digit_Two = d2, Digit_Three = d3]
        in
            return),
  fnType = type function (num as number) as record
    meta [
      Documentation.Name = "Benford",
      Documentation.LongDescription = "This provides a Benford analysis for (up to) the first three digits of a number."
    ]
in
  Value.ReplaceType(Benford, fnType)
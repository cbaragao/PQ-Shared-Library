let Conf = 
 Function.From(type function(z as number, stdev as number, population as number, optional mode as text) as record, (params)=>

let
  
  // check optional parameter and default to s for sample
  m = if params{3} = null then "s" else params{3},

  // subtract 1 from population for samples and make that default
  n = if m = "p" then params{2} else params{2} -1,

  // calculate output
  ci = params{0} * (params{1} / Number.Sqrt(n))

in

  [positive = ci, negative = -ci]),
  
  fnType = type function (z as number, stdev as number, population as number, optional mode as text) as record
    meta [
      Documentation.Name = "Conf",
      Documentation.LongDescription = "This takes parameters and provides the confidence interval range.",
      Documentation.Examples = {
    [Description = "Based on z-score, standard deviation, population, and optional mode (""s"" for sample, ""p"" for population), this generates a confidence interval.",
    Code = "=Conf(1.75, 4, 5000, null)",
    Result="[positive=0.09900485, negative=-0.09900485]"]
}]
      

in
  Value.ReplaceType(Conf, fnType)
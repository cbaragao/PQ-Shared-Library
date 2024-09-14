let
  MegaStDevS = 
    Function.From(
        type function(l as list) as record, (params)=>

        let
            // function for trimmed average
            fnGetTrimmed = 
                (lst as list)=>
                let
                    // figure out 1st and 3rd quartiles
                    Percentile = List.Percentile(lst, {0.25, 0.75}, [PercentileMode=PercentileMode.ExcelInc]),

                    // get the interquartile range
                    IQR = Percentile{1} - Percentile{0},

                    // get the upper limit
                    Upper = Percentile{1} + (1.5 * IQR),

                    // get the lower limit
                    Lower = Percentile{0} - (1.5 * IQR),

                    // trim outliers
                    Select = List.Select(lst, each _ < Upper and _ > Lower),

                    // get the average of the rest
                    Trimmed =  List.Average(Select)

                in

                    Trimmed,
            
            fnGetGeomAvg = 

                // function for the geometric average
                (lst as list, n as number)=>

                let

                    // get the natural log of each number
                    log = List.Transform(lst, each Number.Ln(_)),

                    // take the average, then apply Number.Exp
                    log_avg = Number.Exp(List.Sum(log)/ n )

                in  

                    log_avg,
            
            fnGetWinsorAvg = 

                // function for winsorized average 
                (lst as list)=>

                let 

                    // get the 0.05 and 0.95 percentiles
                    pcntl = List.Percentile(lst, {0.05, 0.95}, [PercentileMode=PercentileMode.ExcelInc]),

                    // if the values are outside of these percentiles, replace them
                    replace = List.Transform(lst, each if _ < pcntl{0} then pcntl{0} else if _ > pcntl{1} then pcntl{1} else _),

                    // take the average of the list with replacements
                    winsor_avg = List.Average(replace)
                in   
                    winsor_avg,
            
            fnGetHarmonicAvg = 

                // function for harmonic mean
                (lst as list, n as number)=>

                let 

                    // convert each value to reciprocals
                    reciprocals = List.Transform(lst, each 1/_),

                    // sum the reciprocals
                    sum_reciprocals = List.Sum(reciprocals),

                    // divide the sum by the count
                    harmonic = n / sum_reciprocals
                in   
                    harmonic,
            
            fnStDevSample = 
            
                // function to manually calculate the standard deviation for a sample population
                (lst as list, rcd as text, degrees as number) =>

                let 
                    stdev = Number.Sqrt(
                                List.Sum(
                                    List.Transform(
                                        lst, 
                                        each Record.Field(_,rcd)
                                    )
                                )
                                / degrees
                            )
                in   
                    stdev,

            // call the functions
            count = List.Count(params{0}),
            arith = List.Average(params{0}),
            trim = fnGetTrimmed(params{0}),
            geom = fnGetGeomAvg(params{0}, count),
            wins = fnGetWinsorAvg(params{0}),
            harm = fnGetHarmonicAvg(params{0}, count),
            dof = count -1,
            loop = 
                List.Generate(
                    ()=>[
                        i = 0, 
                        a = Number.Power(params{0}{0} - arith, 2),
                        t = Number.Power(params{0}{0} - trim, 2),
                        g = Number.Power(params{0}{0} - geom, 2),
                        w = Number.Power(params{0}{0} - wins, 2),
                        h = Number.Power(params{0}{0} - harm, 2)    
                    ], 
                    each [i] <= dof, 
                    each [
                        i=[i]+1,
                        a = Number.Power(params{0}{[i]+1} - arith, 2),
                        t = Number.Power(params{0}{[i]+1} - trim, 2),
                        g = Number.Power(params{0}{[i]+1} - geom, 2),
                        w = Number.Power(params{0}{[i]+1} - wins, 2),
                        h = Number.Power(params{0}{[i]+1} - harm, 2)    
                        ])
        in    
            // return as a record
           [
                arithmetic = List.StandardDeviation(params{0}),
                trimmed = fnStDevSample(loop, "t", dof), 
                geometric = fnStDevSample(loop, "g", dof), 
                winsor = fnStDevSample(loop, "w", dof), 
                harmonic = fnStDevSample(loop, "h", dof),
                usage = "Arithmetic: Standard deviation for sample population based on arithmetic mean #(lf)" &
                        "Trimmed: Consider using when you want to minimize standard error in a dataset with small deviations from normality #(lf)" &
                        "Geometric: Consider when numbers are positive, exponential, and meant to be multiplied together. Example: Average growth rate, interest rates. #(lf)" &
                        "Winsor: Consider using when outliers are present and you want to limit their effect #(lf)" &
                        "Harmonic: Consider using on ratios or fractions, like miles per hour #(lf)"
            ]),
  
  fnType = type function (l as list) as record
    meta [
      Documentation.Name = "MegaStDevSample",
      Documentation.LongDescription = "This function operates on a list and calculates different means and uses those means as part of a sample standard deviation calculation.",
      Documentation.Examples = {
    [Description = "This provides the different values for an example list.",
    Code = "= pqmath.MegaStDevSample({1, 5, 10, 20, 22})",
    Result="[arithmetic = 9.18, trimmed = 9.18, geometric = 10.32, winsor = 9.18, harmonic= 12.83]"]
}]
      

in
  Value.ReplaceType(MegaStDevS, fnType)
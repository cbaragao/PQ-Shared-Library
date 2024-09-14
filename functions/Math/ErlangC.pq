let 
  ErlangC = 
Function.From( type function
  (
    number_of_calls as number, 
    period_of_minutes as number, 
    average_handling_time as number, 
    required_service_level as number, 
    target_answer_time as number,
    maximum_occupancy as number, 
    shrinkage as number
  ) as record, (params) =>
    let
      // define probability of waiting function
      fnProbWait = (num_agents as number, traffic_intensity as number) =>
        let
          a_n = Number.Power(traffic_intensity, num_agents), 
          X = a_n / Number.Factorial(num_agents) * (num_agents / (num_agents - traffic_intensity)), 
          Y = List.Accumulate(
            {0 .. (num_agents - 1)}, 
            0, 
            (state, current) =>
              state + Number.Power(traffic_intensity, current) / Number.Factorial(current)
          ), 
          Pw = X / (Y + X)
        in
          Pw, 
      // define service level function
      fnServiceLevel = (
        num_agents as number, 
        traffic_intensity as number, 
        prob_waiting as number, 
        tat as number, 
        aht as number
      ) =>
        let
          ServiceLevel = 1
            - (prob_waiting * Number.Exp(- (num_agents - traffic_intensity) * (tat / aht)))
        in
          ServiceLevel, 
      
      // determine calls per hour
      calls_per_hour = params{0} * 60 / params{1}, 
      
      // determine the traffic intensity (A)
      A = calls_per_hour * params{2} / 3600, 
      
      // determine the number of agents (N) - start with A + 1 
      N = A + 1, 

      // raise A to the power of N
      A_N = Number.Power(A, N), 

      // determine the probability of waiting
      Pw = fnProbWait(N, A), 

      // determine the service level
      SL = fnServiceLevel(N, A, Pw, params{4}, params{2}), 

      // iterate until you are N-1 from the target number of agents
      Iterate = List.Generate(
        () => [Agents = N, Service_Level = SL], 
        each [Service_Level] < params{3}, 
        each [
          Agents = [Agents] + 1, 
          Service_Level = fnServiceLevel(
            [Agents] + 1, 
            A, 
            fnProbWait([Agents] + 1, A), 
            params{4}, 
            params{2}
          )
        ]
      ), 

      // figure out N-1 so you can generate the result next
      Last = List.LastN(Iterate, 1){0}[Agents], 
      
      
      // generate the result
      Output = [
        Agents = Last + 1, 
        Service_Level = fnServiceLevel(
          Last + 1, 
          A, 
          fnProbWait(Last + 1, A), 
          params{4}, 
          params{2}
        ),
        Occupancy = if A/(Last+1) > params{5} then A/(A/(Last+1)/100) else A/(Last+1),
        Shrinkage = (Last+1)/(1-(params{6}))
      ]
    in

      Output),


fnType = type function (    
    number_of_calls as number, 
    period_of_minutes as number, 
    average_handling_time as number, 
    required_service_level as number, 
    target_answer_time as number,
    maximum_occupancy as number,
    shrinkage as number) 
    as record meta 
[Documentation.Name = "ErlangC",
Documentation.LongDescription = "This calculates the probable amount of agents needed to meet the required service level and the probable service level for that number of agents in a record.",
Documentation.Examples = {
    [Description = "This provides an answer for the following parameters: " &
                    "Number of Calls = 100; " &
                    "Period of Minutes = 30; " &
                    "Average Handling Time (Seconds) = 180; " &
                    "Required Service Level (% expressed as decimal) = .80; " &
                    "Target Answer Time (Seconds) = 20; ",
    Code = "pqmath.ErlangC(100, 30, 180, 0.8, 20)",
    Result="[Agents = 14, Service_Level = 0.888350019]"]
}]
    in  
Value.ReplaceType(ErlangC, fnType)
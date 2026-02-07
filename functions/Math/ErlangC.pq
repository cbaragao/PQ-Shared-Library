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
Documentation.LongDescription = "This calculates the probable number of agents needed to meet the required service level in a call center or contact center environment. Returns a record with Agents (number needed), Service_Level (achieved %), Occupancy (% busy), and Shrinkage (adjusted headcount). Parameters: number_of_calls (total calls), period_of_minutes (time period), average_handling_time (seconds per call), required_service_level (0-1, e.g., 0.80 for 80%), target_answer_time (seconds), maximum_occupancy (0-1, typically 0.85), shrinkage (0-1, typically 0.30 for breaks/training).",
Documentation.Examples = {
    [Description = "Calculate staffing for 100 calls in 30 minutes, 180 second AHT, 80% service level in 20 seconds, 85% max occupancy, 30% shrinkage.",
    Code = "ErlangC(100, 30, 180, 0.8, 20, 0.85, 0.30)",
    Result="[Agents = 14, Service_Level = 0.888350019, Occupancy = ..., Shrinkage = ...]"],
    [Description = "Small call center: 50 calls per hour (60 min period), 5 min AHT, 90% SL in 15 seconds, 80% occupancy, 25% shrinkage.",
    Code = "ErlangC(50, 60, 300, 0.90, 15, 0.80, 0.25)",
    Result="[Agents = ..., Service_Level = ..., Occupancy = ..., Shrinkage = ...]"],
    [Description = "High volume: 500 calls in 60 minutes, 4 min AHT, 85% SL in 30 seconds, 85% occupancy, 35% shrinkage.",
    Code = "ErlangC(500, 60, 240, 0.85, 30, 0.85, 0.35)",
    Result="[Agents = ..., Service_Level = ..., Occupancy = ..., Shrinkage = ...]"]
}]
    in  
Value.ReplaceType(ErlangC, fnType)
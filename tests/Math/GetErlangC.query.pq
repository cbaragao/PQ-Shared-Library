let
    // Include function being tested
    GetErlangC = (
        number_of_calls as number, 
        period_of_minutes as number, 
        average_handling_time as number, 
        required_service_level as number, 
        target_answer_time as number,
        maximum_occupancy as number, 
        shrinkage as number
    ) as record =>
        let
            // define probability of waiting function
            fnProbWait = (num_agents as number, traffic_intensity as number) as number =>
                let
                    a_n = Number.Power(traffic_intensity, num_agents), 
                    X = a_n / Number.Factorial(num_agents) * (num_agents / (num_agents - traffic_intensity)), 
                    Y = List.Accumulate(
                        {0 .. (num_agents - 1)}, 
                        0, 
                        (state as number, current as number) as number =>
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
            ) as number =>
                let
                    ServiceLevel = 1
                        - (prob_waiting * Number.Exp(- (num_agents - traffic_intensity) * (tat / aht)))
                in
                    ServiceLevel, 
            
            // determine calls per hour
            calls_per_hour = number_of_calls * 60 / period_of_minutes, 
            
            // determine the traffic intensity (A)
            A = calls_per_hour * average_handling_time / 3600, 
            
            // determine the number of agents (N) - start with ceiling of A + 1 to ensure integer
            N = Number.RoundUp(A) + 1, 

            // raise A to the power of N
            A_N = Number.Power(A, N), 

            // determine the probability of waiting
            Pw = fnProbWait(N, A), 

            // determine the service level
            SL = fnServiceLevel(N, A, Pw, target_answer_time, average_handling_time), 

            // iterate until you are N-1 from the target number of agents
            Iterate = List.Generate(
                () => [Agents = N, Service_Level = SL], 
                each [Service_Level] < required_service_level, 
                each [
                    Agents = [Agents] + 1, 
                    Service_Level = fnServiceLevel(
                        [Agents] + 1, 
                        A, 
                        fnProbWait([Agents] + 1, A), 
                        target_answer_time, 
                        average_handling_time
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
                    target_answer_time, 
                    average_handling_time
                ),
                Occupancy = if A/(Last+1) > maximum_occupancy then A/(A/(Last+1)/100) else A/(Last+1),
                Shrinkage = (Last+1)/(1-shrinkage)
            ]
        in
            Output,
    
    // Test cases from Documentation.Examples
    TestCases = #table(
        {"TestCase", "Calls", "Minutes", "AHT", "ReqSL", "TAT", "MaxOcc", "Shrink", "Result"},
        {
            {
                "Medium volume - 100 calls/30 min",
                100, 30, 180, 0.8, 20, 0.85, 0.30,
                GetErlangC(100, 30, 180, 0.8, 20, 0.85, 0.30)
            },
            {
                "Small center - 50 calls/hour",
                50, 60, 300, 0.90, 15, 0.80, 0.25,
                GetErlangC(50, 60, 300, 0.90, 15, 0.80, 0.25)
            },
            {
                "High volume - 500 calls/hour",
                500, 60, 240, 0.85, 30, 0.85, 0.35,
                GetErlangC(500, 60, 240, 0.85, 30, 0.85, 0.35)
            }
        }
    ),
    
    // Expand the result record to show all fields
    ExpandedResults = Table.ExpandRecordColumn(
        TestCases, 
        "Result", 
        {"Agents", "Service_Level", "Occupancy", "Shrinkage"},
        {"Agents", "Service_Level", "Occupancy", "Shrinkage"}
    )
in
    ExpandedResults

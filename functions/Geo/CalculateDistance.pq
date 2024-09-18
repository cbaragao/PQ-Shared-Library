let
  CalculateDistance = Function.From(
    type function (lat1 as number, lon1 as number, lat2 as number, lon2 as number, optional measure as number) as number, 
    (params) =>
      let
        // Calculate the difference in latitude and longitude in radians
        dLat = (params{2} - params{0}) * Number.PI / 180.0,
        dLon = (params{3} - params{1}) * Number.PI / 180.0,

        // Convert latitudes to radians
        latitude1 = params{0} * Number.PI / 180.0,
        latitude2 = params{2} * Number.PI / 180.0,

        // Apply the Haversine formula
        a = (Number.Power(Number.Sin(dLat / 2), 2) + 
             Number.Power(Number.Sin(dLon / 2), 2) * 
             Number.Cos(latitude1) * Number.Cos(latitude2)),

        // Determine the radius of the Earth: 6371 km or 3961 miles
        r = if params{4} = 1 then 3961 else 6371,
        c = 2 * Number.Asin(Number.Sqrt(a)),

        // Calculate the distance and round to 4 decimal places
        result = Number.RoundAwayFromZero(r * c, 4)
      in
        result
  ), 
  fnType = type function (lat1 as number, lon1 as number, lat2 as number, lon2 as number, optional measure as number) as number
    meta [
      Documentation.Name = "CalculateDistance", 
      Documentation.LongDescription
        = "This function calculates the distance between two geographic coordinates using the Haversine formula. " & "takes the latitude and longitude of two points and returns the distance in kilometers by default, or " &"in miles if specified.", 
      Documentation.Examples = {
        [
          Description = "Calculate the distance between two points in kilometers.",
          Code        = "=CalculateDistance(34.0522, -118.2437, 40.7128, -74.0060)", 
          Result      = "3935.7463"
        ],
        [
          Description = "Calculate the distance between two points in miles.",
          Code        = "=CalculateDistance(34.0522, -118.2437, 40.7128, -74.0060, 1)", 
          Result      = "2446.9457"
        ]
      }
      ]
in
  Value.ReplaceType(CalculateDistance, fnType)
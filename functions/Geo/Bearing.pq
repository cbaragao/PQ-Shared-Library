let
  Bearing = Function.From(
    type function (lat1_rad as number, lat2_rad as number, lon1_rad as number, lon2_rad as number) as record, 
    (params) =>
      let
        // Calculate the initial bearing from the start point to the end point
        Source = Number.Atan2(
          Number.Sin(params{3} - params{2}) * Number.Cos(params{1}),
          Number.Cos(params{0}) * Number.Sin(params{1}) - Number.Sin(params{0}) * Number.Cos(params{1}) * Number.Cos(params{3} - params{2})
        ),
        
        // Convert the bearing from radians to degrees
        FromRadians = Source * (180 / Number.PI),
        
        // Correct negative bearings by adding 360 and taking modulo 360
        CorrectNegative = Number.Mod(FromRadians + 360, 360),
        
        // Round the bearing to the nearest whole number
        Round = Number.RoundUp(CorrectNegative),
        
        // Determine the compass direction based on the rounded bearing
        DirectionResult =
          if Round <= 11 or Round >= 349 then [Direction = "N", Sort = 1]
          else if Round <= 33 then [Direction = "NNE", Sort = 2]
          else if Round <= 55 then [Direction = "NE", Sort = 3]
          else if Round <= 77 then [Direction = "ENE", Sort = 4]
          else if Round <= 99 then [Direction = "E", Sort = 5]
          else if Round <= 121 then [Direction = "ESE", Sort = 6]
          else if Round <= 143 then [Direction = "SE", Sort = 7]
          else if Round <= 166 then [Direction = "SSE", Sort = 8]
          else if Round <= 189 then [Direction = "S", Sort = 9]
          else if Round <= 212 then [Direction = "SSW", Sort = 10]
          else if Round <= 234 then [Direction = "SW", Sort = 11]
          else if Round <= 256 then [Direction = "WSW", Sort = 12]
          else if Round <= 279 then [Direction = "W", Sort = 13]
          else if Round <= 302 then [Direction = "WNW", Sort = 14]
          else if Round <= 325 then [Direction = "NW", Sort = 15]
          else if Round >= 348 then [Direction = "NNW", Sort = 16]
          else [Direction = "UNK", Sort = -1]
      in
        DirectionResult
  ), 
  fnType = type function (lat1_rad as number, lat2_rad as number, lon1_rad as number, lon2_rad as number) as record
    meta [
      Documentation.Name = "CalculateDirection", 
      Documentation.LongDescription
        = "This function calculates the compass direction from one geographic coordinate to another. It takes the latitude and longitude of two points in radians and returns the compass direction as a record with the direction and sort order.", 
      Documentation.Examples = {
        [
          Description = "Calculate the direction from point A to point B.",
          Code        = "=CalculateDirection(0.785398, 0.523599, -1.5708, -1.0472)", 
          Result      = "[Direction = 'ESE', Sort = 6]"
        ]
      }
    ]
in
  Value.ReplaceType(Bearing, fnType)
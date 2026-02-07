let
    // Include function being tested
    MeasureDistance = (lat1 as number, lon1 as number, lat2 as number, lon2 as number, optional measure as number) as number =>
        let
            // Calculate the difference in latitude and longitude in radians
            dLat = (lat2 - lat1) * Number.PI / 180.0,
            dLon = (lon2 - lon1) * Number.PI / 180.0,

            // Convert latitudes to radians
            latitude1 = lat1 * Number.PI / 180.0,
            latitude2 = lat2 * Number.PI / 180.0,

            // Apply the Haversine formula
            a = (Number.Power(Number.Sin(dLat / 2), 2) + 
                 Number.Power(Number.Sin(dLon / 2), 2) * 
                 Number.Cos(latitude1) * Number.Cos(latitude2)),

            // Determine the radius of the Earth: 6371 km or 3961 miles
            r = if measure = 1 then 3961 else 6371,
            c = 2 * Number.Asin(Number.Sqrt(a)),

            // Calculate the distance and round to 4 decimal places
            result = Number.RoundAwayFromZero(r * c, 4)
        in
            result,
    
    // Test cases
    Source = #table(
        {"TestCase", "lat1", "lon1", "lat2", "lon2", "measure", "Expected", "Actual", "Pass"},
        {
            {
                "Distance in kilometers (Los Angeles to New York)",
                34.0522,
                -118.2437,
                40.7128,
                -74.0060,
                null,
                3935.7463,
                MeasureDistance(34.0522, -118.2437, 40.7128, -74.0060),
                MeasureDistance(34.0522, -118.2437, 40.7128, -74.0060) = 3935.7463
            },
            {
                "Distance in miles (Los Angeles to New York)",
                34.0522,
                -118.2437,
                40.7128,
                -74.0060,
                1,
                2446.9457,
                MeasureDistance(34.0522, -118.2437, 40.7128, -74.0060, 1),
                MeasureDistance(34.0522, -118.2437, 40.7128, -74.0060, 1) = 2446.9457
            }
        }
    )
in
    Source

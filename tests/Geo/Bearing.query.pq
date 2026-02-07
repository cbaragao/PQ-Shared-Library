// Test cases for Bearing function
let
    Source = #table(
        {"TestCase", "lat1_rad", "lat2_rad", "lon1_rad", "lon2_rad", "Expected_Direction", "Expected_Sort", "Actual_Result", "Pass"},
        {
            {
                "Example from documentation",
                0.785398,
                0.523599,
                -1.5708,
                -1.0472,
                "ESE",
                6,
                Bearing(0.785398, 0.523599, -1.5708, -1.0472),
                Bearing(0.785398, 0.523599, -1.5708, -1.0472)[Direction] = "ESE" and Bearing(0.785398, 0.523599, -1.5708, -1.0472)[Sort] = 6
            }
        }
    )
in
    Source

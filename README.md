# Power Query Function Library

Welcome to the Power Query Function Library! This repository is a collection of Power Query functions that I have gathered and developed over the years. Some of these functions were found online, but the majority were coded personally. 

## Structure

- **functions/**: Contains subdirectories categorized by function type. Each `.pq` file implements a single Power Query function and is grouped by category (DateTime, Geo, Math, R, SQL, String, Tbl, Utils, UX).

Note: the previous `sharedmaster` bundling files have been removed — functions can be used directly from the `functions/` folder or imported individually into Power BI / Power Query.

## Methodology

The bundling method used here mimics Kim Burgess's approach of consolidating functions into a single file. This allows for easier management and reuse of code across different projects.

## Acknowledgements

Special thanks to:
- **Injae Park**: For his innovative method of refreshing code directly from GitHub. [Watch his video here](https://www.youtube.com/watch?v=GXFxiEVAmfI&lc=Ugzqdez_1gwAqt2egbV4AaABAg.A8KV2MP8OcAA8LJqlcSEiT).
- **John Kerski**: For his insightful article on code reuse with Power Query. [Read his article here](https://www.kerski.tech/bringing-dataops-to-power-bi-part13/).

## Getting Started

1. Clone the repository:
    ```sh
    git clone https://github.com/cbaragao/PQ-Shared-Library.git
    ```
2. Import a specific function into Power BI / Power Query by opening the `.pq` file and copying the function body into a Blank Query (Advanced Editor), or by using your preferred bundling workflow.

3. Right click any function that you want to use to instantiate it and give it an appropriate name.

## Wiki

I used Copilot to put together a [wiki](https://github.com/cbaragao/PQ-Shared-Library/wiki) for all functions added thus far.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License.

---

Feel free to modify this as needed! Let me know if there's anything else you'd like to add or change.

## Available functions (by folder)

- DateTime:
    - ConvertToRoundedDateTime
- Geo:
    - MeasureBearing
    - MeasureDistance
- Math:
    - CalculateEWMA
    - GetConfidenceInterval
    - GetErlangC
    - GetFactors
    - NewRandomNumbers
    - TestBenford
- R:
    - GetLinearModelCoefficients
    - InvokeLogitPrediction
- SQL:
    - InvokeSQLQuery
- String:
    - ConvertToEncodedText
    - GetFileText
    - RemoveChars
    - RemoveHTMLTags
- Tbl:
    - AddRandomNumber
    - ConvertColumnToList
    - ConvertDateTimeZoneToDate
    - RoundColumns
    - UpdateColumnNames
- Utils:
    - GetFunctionMetadata
    - NewBatches
    - SelectCase
    - SelectDynamicList
- UX:
    - GetColorHue
    - GetColorScheme
    - GetCompColor
    - GetFontColor
    - GetHexValue
    - GetLuminosity
    - GetMedianAspectRatio
    - GetRGBValue
    - TestColorBlindness
    - TestColorContrast
    - TestWebAimContrast

If you want this list exported to a machine-readable file (JSON/CSV) or added to the repository wiki, I can generate that next.

# Power Query Function Library

A collection of Power Query M functions for Power BI, organized by category. Each `.pq` file is self-contained and can be used independently.

## Structure

```
functions/   — one .pq file per function, grouped by category
tests/       — portable test queries mirroring functions/ structure
documentation/ — project docs, naming conventions, lessons learned
```

## Getting Started

1. Clone the repository:
    ```sh
    git clone https://github.com/cbaragao/PQ-Shared-Library.git
    ```
2. Open the `.pq` file for the function you want, copy the entire contents into a Blank Query in Power BI Desktop (Home → Advanced Editor), and name the query to match the function identifier.

## Wiki

A [wiki](https://github.com/cbaragao/PQ-Shared-Library/wiki) with additional documentation is available on GitHub.

## Contributing

Contributions are welcome. Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License.

---

## Function Reference

### DateTime

| Function | Description |
|---|---|
| `ConvertToRoundedDateTime` | Rounds a datetime value to a specified minute interval. |

### Geo

| Function | Description |
|---|---|
| `MeasureBearing` | Calculates the compass bearing between two geographic coordinates, returning direction and sort order. |
| `MeasureDistance` | Calculates the distance between two geographic coordinates using the Haversine formula (km or miles). |

### Math

| Function | Description |
|---|---|
| `CalculateEWMA` | Computes an exponential weighted moving average for a list using a smoothing factor. |
| `GetConfidenceInterval` | Calculates a confidence interval range from a z-score, standard deviation, and population size. |
| `GetErlangC` | Calculates the number of agents needed to meet a target service level using the Erlang C formula. |
| `GetFactors` | Returns a sorted list of all integer factors of a given number. |
| `NewRandomNumbers` | Generates a sorted list of distinct random integers up to a specified maximum using a reproducible seed. |
| `TestBenford` | Tests a number against Benford's Law by calculating expected probabilities for the first three leading digits. |

### R

| Function | Description |
|---|---|
| `GetLinearModelCoefficients` | Runs a generalized linear model in R and returns coefficients with statistical significance indicators. |
| `InvokeLogitPrediction` | Runs a logistic regression in R and returns predicted probabilities and binary predictions. |

### SQL

| Function | Description |
|---|---|
| `InvokeSQLQuery` | Executes a SQL query against a data source with query folding support. |

### String

| Function | Description |
|---|---|
| `ConvertListToText` | Joins non-null, non-empty list values into a single text string using a specified separator. |
| `ConvertToEncodedText` | Encodes text by converting each character to its 3-digit ASCII number. |
| `GetFileText` | Reads a file and returns all lines as a single text string separated by line feeds. |
| `RemoveChars` | Removes unwanted characters from text with options for uppercase, lowercase, numbers, and special characters. |
| `RemoveHTMLTags` | Strips HTML tags from a string and returns the plain text content. |
| `SplitAndValidate` | Splits text on a delimiter, applies a named pattern rule to each part, and returns a table with per-rule success flags. |

### Tbl

| Function | Description |
|---|---|
| `AddRandomNumber` | Adds a reproducible `Random` column to a table using a seed value. |
| `ConvertColumnToList` | Extracts a specified column from a table and returns it as a list. |
| `ConvertDateTimeZoneToDate` | Converts datetime or datetimezone columns to date type by removing the time component. |
| `RoundColumns` | Rounds all numeric columns in a table to a specified number of decimal places, with optional exclusions. |
| `UpdateColumnNames` | Replaces text patterns in column names and applies proper casing. |

### Utils

| Function | Description |
|---|---|
| `GetFunctionMetadata` | Returns metadata (name or description) for a given function. |
| `NewBatches` | Generates a table of batch ranges from a batch size, total size, and base value. |
| `SelectCase` | Evaluates a value against a list of predicate/result pairs and returns the first matching result, or a default. |
| `SelectDynamicList` | Selects items from a list using individual indices or range notation (`start:end`). |

### UX

| Function | Description |
|---|---|
| `GetColorHue` | Returns the hue angle (0–360°) for a hex color code. |
| `GetColorScheme` | Retrieves a color scheme from The Color API for a given hex code and mode. |
| `GetCompColor` | Calculates the complementary color by inverting RGB channel values. |
| `GetHexValue` | Converts RGB values (0–255) to a `#RRGGBB` hex color code. |
| `GetLuminosity` | Calculates the HSL luminosity of a hex color, returning a value between 0 and 1. |
| `GetMedianAspectRatio` | Computes the median slope and corresponding aspect ratio between two numeric series. |
| `GetRGBValue` | Converts a hex color code to comma-separated RGB values (0–255). |
| `TestColorBlindness` | Simulates how a color appears under various types and severities of color blindness. |
| `TestColorContrast` | Tests the contrast ratio between two hex colors against WCAG accessibility standards. |
| `TestWebAimContrast` | Tests color contrast using the WebAIM API and returns the ratio and WCAG 2.0 pass/fail results. |


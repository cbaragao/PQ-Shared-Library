# Power Query Function Library

Welcome to the Power Query Function Library! This repository is a collection of Power Query functions that I have gathered and developed over the years. Some of these functions were found online, but the majority were coded personally. 

## Structure

- **functions/**: Contains subdirectories categorized by function type.
- **shared master/**: Contains a PowerShell script that bundles all the functions into a master Power Query file, which can be imported into Power BI and Excel.

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
2. Navigate to the `shared master` directory and import the sharedmaster.pq file into Power BI:

3. Right click any function that you want to use to instantiate it and don't forget to name it.

## Wiki

I used Copilot to put together a [wiki](https://github.com/cbaragao/PQ-Shared-Library/wiki) for all functions added thus far.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License.

---

Feel free to modify this as needed! Let me know if there's anything else you'd like to add or change.

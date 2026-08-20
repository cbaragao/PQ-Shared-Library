let
  GetKeyCandidates = (t as table, optional threshold as nullable number) as table =>
    let
      thresholdValue = threshold ?? 0.85,
      // Buffer once so repeated profiling and per-pair scans below don't re-read the source table
      bufferedTable = Table.Buffer(t, [BufferMode = BufferMode.Delayed]),

      // Per-column uniqueness ratio and single-column key classification
      profile = Table.Profile(bufferedTable),
      // Compute the distinct ratio and single-column classification for every column
      withUniqueness = Table.AddColumn(
        profile,
        "Uniqueness",
        each
          let
            pct = [DistinctCount] / [Count]
          in
            [
              Pct = pct,
              Classification =
                if pct = 1 then
                  "Perfect key"
                else if pct >= thresholdValue then
                  "Nearly Key"
                else
                  "Not a Key"
            ],
        type record
      ),
      singleColumnResults = Table.ExpandRecordColumn(
        Table.SelectColumns(withUniqueness, {"Column", "Uniqueness"}, MissingField.Error),
        "Uniqueness",
        {"Pct", "Classification"},
        {"Percent Unique", "Classification"}
      ),
      typedSingleColumnResults = Table.TransformColumnTypes(
        singleColumnResults,
        {{"Percent Unique", Percentage.Type}, {"Classification", type text}}
      ),

      // Composite keys are only checked for column pairs that are not already a key on their own;
      // combinations beyond two columns grow combinatorially and are too expensive to evaluate here
      candidateColumns = Table.SelectColumns(
        Table.SelectRows(typedSingleColumnResults, each [Percent Unique] < 1),
        {"Column"},
        MissingField.Error
      ),
      // Buffer so the nested table isn't recomputed for every row during the self cross-join below
      bufferedCandidateColumns = Table.Buffer(candidateColumns, [BufferMode = BufferMode.Delayed]),
      // Self cross-join via a nested table column produces every ordered pair of candidate columns
      withCartesian = Table.AddColumn(candidateColumns, "Cartesian", each bufferedCandidateColumns, type table),
      cartesianColumns = Table.ExpandTableColumn(
        withCartesian,
        "Cartesian",
        {"Column"},
        {"Cartesian.Column"}
      ),
      distinctColumnPairs = Table.SelectRows(cartesianColumns, each [Column] < [Cartesian.Column]),

      // For each pair, combine the two columns (as text) into a single key and profile its uniqueness
      pairProfiles = Table.AddColumn(
        distinctColumnPairs,
        "Subtable",
        each
          let
            pairColumns = {[Column], [Cartesian.Column]}
          in
            Table.Profile(
              Table.CombineColumns(
                Table.SelectColumns(
                  Table.TransformColumnTypes(bufferedTable, List.Zip({pairColumns, List.Repeat({type text}, List.Count(pairColumns))})),
                  pairColumns,
                  MissingField.Error
                ),
                pairColumns,
                Combiner.CombineTextByDelimiter(Character.FromNumber(31), QuoteStyle.None),
                "Keys"
              )
            ),
        type table
      ),
      isFullCompositeKey = Table.TransformColumns(
        pairProfiles,
        {"Subtable", each if _{0}[DistinctCount] = _{0}[Count] then 1 else 0, Percentage.Type}
      ),
      // Keep only pairs whose combined values are fully distinct, then label them as composite keys
      compositeResults = Table.AddColumn(
        Table.RenameColumns(
          Table.SelectRows(isFullCompositeKey, each [Subtable] = 1),
          {{"Cartesian.Column", "Second Column"}, {"Subtable", "Percent Unique"}}
        ),
        "Classification",
        each "Composite key",
        type text
      ),

      combinedResults = Table.Combine({typedSingleColumnResults, compositeResults}),
      withSecondColumn = Table.ReplaceValue(combinedResults, null, "N/A", Replacer.ReplaceValue, {"Second Column"}),
      result = Table.TransformColumnTypes(Table.ReorderColumns(withSecondColumn, {"Column", "Second Column", "Percent Unique", "Classification"}, MissingField.Error),{"Second Column", type text})
    in
      result,

  fnType = type function (t as table, optional threshold as nullable number) as table
    meta [
      Documentation.Name = "GetKeyCandidates",
      Documentation.LongDescription = "Analyzes each column of a table for uniqueness and classifies it as a Perfect key (100% distinct), Nearly Key (distinct ratio at or above the optional threshold, 0.85 by default), or Not a Key. For columns that are not already a key on their own, also checks every unordered pair of those columns for a composite key: a pair is reported as a Composite key when combining their values produces a fully distinct result. Composite key detection is limited to two-column combinations, since checking larger combinations grows combinatorially and would be too expensive to evaluate in Power Query.",
      Documentation.Examples = {
        [
          Description = "Classify a single-column key alongside a non-unique column.",
          Code = "GetKeyCandidates(#table(type table [ID = number, Category = text], {{1, ""A""}, {2, ""A""}, {3, ""B""}}))",
          Result = "#table({""Column"", ""Second Column"", ""Percent Unique"", ""Classification""}, {{""ID"", ""N/A"", 1, ""Perfect key""}, {""Category"", ""N/A"", 0.66666666666666663, ""Not a Key""}})"
        ],
        [
          Description = "Detect a composite key formed by two columns that are not individually unique.",
          Code = "GetKeyCandidates(#table(type table [A = number, B = number], {{1, 1}, {1, 2}, {2, 1}, {2, 2}}))",
          Result = "#table({""Column"", ""Second Column"", ""Percent Unique"", ""Classification""}, {{""A"", ""N/A"", 0.5, ""Not a Key""}, {""B"", ""N/A"", 0.5, ""Not a Key""}, {""A"", ""B"", 1, ""Composite key""}})"
        ]
      }
    ]
in
  Value.ReplaceType(GetKeyCandidates, fnType)
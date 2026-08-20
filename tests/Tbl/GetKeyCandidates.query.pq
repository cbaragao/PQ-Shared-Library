let
  // Include function being tested
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

  // Helper to fetch a single-column classification row, independent of composite-row ordering
  GetSingleRow = (t as table, columnName as text) as record =>
    Table.SelectRows(t, each [Column] = columnName and [Second Column] = "N/A"){0},

  // Helper to fetch a composite-key row for a given column pair, independent of row order
  GetCompositeRow = (t as table, columnName as text, secondColumnName as text) as record =>
    Table.SelectRows(t, each [Column] = columnName and [Second Column] = secondColumnName){0},

  // Test 1: A perfectly unique column is a Perfect key; a non-unique column with no valid partner is Not a Key
  Test1_Input = #table(type table [ID = number, Category = text], {{1, "A"}, {2, "A"}, {3, "B"}}),
  Test1_Result = GetKeyCandidates(Test1_Input),
  Test1_RowCount = Table.RowCount(Test1_Result) = 2,
  Test1_ID_Row = GetSingleRow(Test1_Result, "ID"),
  Test1_Category_Row = GetSingleRow(Test1_Result, "Category"),
  Test1_ID_Pass = Test1_ID_Row[Percent Unique] = 1 and Test1_ID_Row[Classification] = "Perfect key",
  Test1_Category_Pass = Test1_Category_Row[Classification] = "Not a Key",
  Test1_Pass = Test1_RowCount and Test1_ID_Pass and Test1_Category_Pass,

  // Test 2: Two columns that are not individually unique form a composite key together
  Test2_Input = #table(type table [A = number, B = number], {{1, 1}, {1, 2}, {2, 1}, {2, 2}}),
  Test2_Result = GetKeyCandidates(Test2_Input),
  Test2_RowCount = Table.RowCount(Test2_Result) = 3,
  Test2_A_Row = GetSingleRow(Test2_Result, "A"),
  Test2_B_Row = GetSingleRow(Test2_Result, "B"),
  Test2_Composite_Row = GetCompositeRow(Test2_Result, "A", "B"),
  Test2_Pass =
    Test2_RowCount
    and Test2_A_Row[Classification] = "Not a Key"
    and Test2_B_Row[Classification] = "Not a Key"
    and Test2_Composite_Row[Classification] = "Composite key"
    and Test2_Composite_Row[Percent Unique] = 1,

  // Test 3: The optional threshold parameter changes whether a partially-unique column is "Nearly Key"
  Test3_Input = #table(type table [X = number], {{1}, {1}, {2}, {3}, {4}}),
  Test3_DefaultResult = GetSingleRow(GetKeyCandidates(Test3_Input), "X"),
  Test3_LowerThresholdResult = GetSingleRow(GetKeyCandidates(Test3_Input, 0.75), "X"),
  Test3_Pass =
    Test3_DefaultResult[Classification] = "Not a Key"
    and Test3_LowerThresholdResult[Classification] = "Nearly Key",

  // Test 4: A single-column table has no possible composite partner and reports "N/A" for Second Column
  Test4_Input = #table(type table [OnlyCol = text], {{"A"}, {"A"}, {"B"}}),
  Test4_Result = GetKeyCandidates(Test4_Input),
  Test4_Pass =
    Table.RowCount(Test4_Result) = 1
    and Test4_Result{0}[Second Column] = "N/A"
    and Test4_Result{0}[Classification] = "Not a Key",

  // Test 5: Null handling - a null argument in place of a table raises an error
  Test5_Result = try GetKeyCandidates(null) otherwise "Error",
  Test5_Pass = Test5_Result = "Error",

  // Test 6: Boundary case - an empty table does not error; an empty column is classified as "Not a Key"
  Test6_Input = #table(type table [ID = number], {}),
  Test6_Result = GetKeyCandidates(Test6_Input),
  Test6_Pass =
    Table.RowCount(Test6_Result) = 1
    and Number.IsNaN(Test6_Result{0}[Percent Unique])
    and Test6_Result{0}[Classification] = "Not a Key",

  // Consolidate test results
  TestResults = #table(
    {"TestCase", "Expected", "Pass"},
    {
      {"Test1: Perfect key and Not a Key are classified correctly", true, Test1_Pass},
      {"Test2: Composite key detected for non-unique column pair", true, Test2_Pass},
      {"Test3: Optional threshold changes Nearly Key classification", true, Test3_Pass},
      {"Test4: Single-column table reports N/A for Second Column", true, Test4_Pass},
      {"Test5: Null table argument raises an error", true, Test5_Pass},
      {"Test6: Empty table does not error and is Not a Key", true, Test6_Pass}
    }
  )
in
  TestResults

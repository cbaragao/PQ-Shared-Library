let
  // Include function being tested
  GetDataQualityMetrics = (t as table) as table =>
    let
      // Unpivots every column, flags blanks/errors with sentinels, and pivots per-column counts;
      // only the sentinel(s) that actually occur anywhere in the table become output columns
      getBlanksAndErrors = (t as table) as table =>
        let
          unpivotedColumns = Table.UnpivotOtherColumns(t, {}, "Attribute", "Value"),
          replaceBlanks = Table.ReplaceValue(unpivotedColumns, "", "~~Blank~~", Replacer.ReplaceValue, {"Value"}),
          replaceErrors = Table.ReplaceErrorValues(replaceBlanks, {{"Value", "~~Error~~"}}),
          selectBlanksAndErrors = Table.SelectRows(replaceErrors, each [Value] = "~~Blank~~" or [Value] = "~~Error~~"),
          groupedRows = Table.Group(selectBlanksAndErrors, {"Attribute", "Value"}, {{"Count", each Table.RowCount(_), Int64.Type}}, GroupKind.Global),
          // Pivot only the sentinel values that actually occur, so Blank/Error columns are added dynamically
          pivotedColumn = Table.Pivot(groupedRows, List.Distinct(groupedRows[Value]), "Value", "Count", List.Sum),
          renameColumns = Table.TransformColumnNames(pivotedColumn, each Text.Replace(_, "~", ""), null),
          replaceNullCounts = Table.ReplaceValue(renameColumns, null, 0, Replacer.ReplaceValue, Table.ColumnNames(renameColumns))
        in
          replaceNullCounts,

      // Every column after the first ("Attribute"/"Column") is a data-value column, not a key column
      getValueColumns = (t as table) as list =>
        List.RemoveFirstN(Table.ColumnNames(t), 1),

      profile = Table.Buffer(Table.Profile(t), [BufferMode = BufferMode.Delayed]),
      rowCount = Table.RowCount(t),
      // Null % and Distinct % come directly from the built-in profiler
      withRatios = Table.AddColumn(
        profile,
        "Quality",
        each
          let
            r = [C = [Count], NC = [NullCount], DC = [DistinctCount]]
          in
            [NullPct = r[NC] / r[C], DistinctPct = r[DC] / r[C]]
      ),
      initial = Table.SelectColumns(withRatios, {"Column", "Quality"}, MissingField.Error),
      groupedBlanksErrors = getBlanksAndErrors(t),
      blankErrorPct =
        let
          colnames = getValueColumns(groupedBlanksErrors)
        in
          Table.TransformColumns(groupedBlanksErrors, List.Zip({colnames, List.Repeat({each _ / rowCount}, List.Count(colnames))})),
      renameBlankErrorPct = Table.TransformColumnNames(blankErrorPct, each if _ <> "Attribute" then _ & "Pct" else _),
      // Left outer join keeps every profiled column even when it has no blanks or errors of its own
      joined = Table.Join(initial, "Column", renameBlankErrorPct, "Attribute", JoinKind.LeftOuter),
      expandedQuality = Table.ExpandRecordColumn(joined, "Quality", {"NullPct", "DistinctPct"}, {"NullPct", "DistinctPct"}),
      removedAttribute = Table.RemoveColumns(expandedQuality, "Attribute", MissingField.Ignore),
      renameAllPctColumns = Table.TransformColumnNames(removedAttribute, each if Text.Contains(_, "Pct") then Text.Replace(_, "Pct", " %") else _),
      replaceNulls = Table.ReplaceValue(renameAllPctColumns, null, 0, Replacer.ReplaceValue, getValueColumns(renameAllPctColumns)),
      changedType =
        let
          colnames = getValueColumns(replaceNulls)
        in
          Table.TransformColumnTypes(replaceNulls, List.Zip({colnames, List.Repeat({Percentage.Type}, List.Count(colnames))})),
      // Quality = 1 minus every percentage column present except Distinct %, which is reported separately
      addQuality = Table.AddColumn(
        changedType,
        "Quality",
        each List.Accumulate(
          Record.ToList(Record.RemoveFields(_, {"Column", "Distinct %"})),
          1,
          (state as number, current as number) as number => state - current
        ),
        Percentage.Type
      )
    in
      addQuality,

  // Helper to fetch a single column's metrics row by name
  GetColumnRow = (t as table, columnName as text) as record =>
    Table.SelectRows(t, each [Column] = columnName){0},

  // Test 1: Null and blank are counted separately per column; a fully populated numeric column scores perfectly
  Test1_Input = #table(type table [A = number, B = text], {{1, "x"}, {2, null}, {3, ""}, {4, "y"}}),
  Test1_Result = GetDataQualityMetrics(Test1_Input),
  Test1_A_Row = GetColumnRow(Test1_Result, "A"),
  Test1_B_Row = GetColumnRow(Test1_Result, "B"),
  Test1_Pass =
    Test1_A_Row[#"Null %"] = 0 and Test1_A_Row[#"Blank %"] = 0 and Test1_A_Row[Quality] = 1
    and Test1_B_Row[#"Null %"] = 0.25 and Test1_B_Row[#"Blank %"] = 0.25 and Test1_B_Row[Quality] = 0.5
    and not Table.HasColumns(Test1_Result, "Error %"),

  // Test 2: Distinct % is reported separately and does not reduce Quality; no Blank %/Error % columns when neither occurs
  Test2_Input = #table(type table [Category = text], {{"A"}, {"A"}, {"B"}, {"B"}}),
  Test2_Result = GetDataQualityMetrics(Test2_Input),
  Test2_Row = GetColumnRow(Test2_Result, "Category"),
  Test2_Pass =
    Test2_Row[#"Distinct %"] = 0.5 and Test2_Row[Quality] = 1
    and not Table.HasColumns(Test2_Result, "Blank %")
    and not Table.HasColumns(Test2_Result, "Error %"),

  // Test 3: An error value is counted under Error %, separately from Null % and Blank %
  Test3_Input = #table(type table [Category = text], {{"A"}, {"A"}, {"B"}, {Number.FromText("abc")}}),
  Test3_Result = try GetDataQualityMetrics(Test3_Input) otherwise "Error",
  Test3_Pass = Test3_Result <> "Error",

  // Test 4: A whitespace-only value is not treated as blank, since blank is strictly an empty text string
  Test4_Input = #table(type table [Col = text], {{"A"}, {"   "}, {"B"}, {"C"}}),
  Test4_Result = GetDataQualityMetrics(Test4_Input),
  Test4_Row = GetColumnRow(Test4_Result, "Col"),
  Test4_Pass =
    Test4_Row[#"Distinct %"] = 1 and Test4_Row[Quality] = 1
    and not Table.HasColumns(Test4_Result, "Blank %"),

  // Test 5: Null table argument raises an error
  Test5_Result = try GetDataQualityMetrics(null) otherwise "Error",
  Test5_Pass = Test5_Result = "Error",

  // Test 6: Boundary case - an empty table does not error; percentages are NaN and no Blank %/Error % columns exist
  Test6_Input = #table(type table [ID = number], {}),
  Test6_Result = GetDataQualityMetrics(Test6_Input),
  Test6_Row = GetColumnRow(Test6_Result, "ID"),
  Test6_Pass =
    Table.RowCount(Test6_Result) = 1
    and Number.IsNaN(Test6_Row[#"Null %"]) and Number.IsNaN(Test6_Row[#"Distinct %"]) and Number.IsNaN(Test6_Row[Quality])
    and not Table.HasColumns(Test6_Result, "Blank %"),

  // Consolidate test results
  TestResults = #table(
    {"TestCase", "Expected", "Pass"},
    {
      {"Test1: Null and blank are counted separately per column", true, Test1_Pass},
      {"Test2: Distinct % does not reduce Quality and unused columns are omitted", true, Test2_Pass},
      {"Test3: An error value is counted under Error %", true, Test3_Pass},
      {"Test4: Whitespace-only value is not treated as blank", true, Test4_Pass},
      {"Test5: Null table argument raises an error", true, Test5_Pass},
      {"Test6: Empty table does not error and reports NaN", true, Test6_Pass}
    }
  )
in
  TestResults

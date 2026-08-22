let
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

  fnType = type function (t as table) as table
    meta [
      Documentation.Name = "GetDataQualityMetrics",
      Documentation.LongDescription = "Calculates column-level data quality metrics including Null %, Distinct %, Blank %, Error %, and an overall Quality score. A blank value is defined strictly as an empty text string (""""); whitespace-only values are not treated as blank. The Quality score is computed as 1 - Null % - Blank % - Error %. Distinctness is reported separately and does not influence the Quality score because low cardinality may be expected for categorical columns. The function is intended to measure structural completeness and usability of data rather than business accuracy or validity. Blank % and Error % columns are included only when at least one blank or error value occurs somewhere in the table.",
      Documentation.Examples = {
        [
          Description = "Profile a table with a fully populated numeric column and a text column containing a null and a blank value; no errors occur anywhere, so no Error % column is produced.",
          Code = "GetDataQualityMetrics(#table(type table [A = number, B = text], {{1, ""x""}, {2, null}, {3, """"}, {4, ""y""}}))",
          Result = "#table({""Column"", ""Null %"", ""Distinct %"", ""Blank %"", ""Quality""}, {{""A"", 0, 1, 0, 1}, {""B"", 0.25, 1, 0.25, 0.5}})"
        ],
        [
          Description = "A column with duplicate values has a lower Distinct %, but Quality stays 1 since Distinct % does not factor into it; no Blank % or Error % column is produced since neither occurs anywhere.",
          Code = "GetDataQualityMetrics(#table(type table [Category = text], {{""A""}, {""A""}, {""B""}, {""B""}}))",
          Result = "#table({""Column"", ""Null %"", ""Distinct %"", ""Quality""}, {{""Category"", 0, 0.5, 1}})"
        ]
      }
    ]
in
  Value.ReplaceType(GetDataQualityMetrics, fnType)


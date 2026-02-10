let 
// Source for matrices of values: https://www.inf.ufrgs.br/~oliveira/pubs_files/CVD_Simulation/CVD_Simulation.html
    CheckColorBlind = 

// Calculate RGB based on hex value
Function.From( type function(HEX as text) as table, (params) =>
  let
    // Split strings into list by each character, convert to upper, remove hash
    Source = if params{0} <> "" then Text.Upper(Text.AfterDelimiter(Text.From(params{0}), "#")) else "#000000", 
    // Split the Source by each character
    SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source), 
    GetColor = (hexlist) =>
      let
        // Build the RGB list
        RGB = List.Combine({{"0" .. "9"}, {"A" .. "F"}}), 
        // Sub function to figure out RGB value
        GetRGB = (cval1, cval2) =>
          let
            RGBVal = (Number.From(cval1) * 16) + Number.From(cval2)
          in
            RGBVal, 
        // Get positions of each digit
        r = GetRGB(List.PositionOf(RGB, hexlist{0}), List.PositionOf(RGB, hexlist{1})), 
        g = GetRGB(List.PositionOf(RGB, hexlist{2}), List.PositionOf(RGB, hexlist{3})), 
        b = GetRGB(List.PositionOf(RGB, hexlist{4}), List.PositionOf(RGB, hexlist{5})), 
        // Combine R,G,B hex values to one hex value
        FinalRGB = Text.Combine({Text.From(r), Text.From(g), Text.From(b)}, ",")
      in
        FinalRGB, 
    CheckColorBlind = (red as number, green as number, blue as number) =>
      let
        tbl = Table.FromRecords(
          {
            [
              Severity = 0.0, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 1.0, g = 0.0, b = 0.0], 
                  [r = 0.0, g = 1.0, b = 0.0], 
                  [r = 0.0, g = 0.0, b = 1.0]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 1.0, g = 0.0, b = 0.0], 
                  [r = 0.0, g = 1.0, b = 0.0], 
                  [r = 0.0, g = 0.0, b = 1.0]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.0, g = 0.0, b = 0.0], 
                  [r = 0.0, g = 1.0, b = 0.0], 
                  [r = 0.0, g = 0.0, b = 1.0]
                }
              )
            ], 
            [
              Severity = 0.1, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.856167, g = 0.182038, b = - 0.038205], 
                  [r = 0.029342, g = 0.955115, b = 0.015544], 
                  [r = - 0.002880, g = - 0.001563, b = 1.004443]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.866435, g = 0.177704, b = - 0.044139], 
                  [r = 0.049567, g = 0.939063, b = 0.011370], 
                  [r = - 0.003453, g = 0.007233, b = 0.996220]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 0.926670, g = 0.092514, b = - 0.019184], 
                  [r = 0.021191, g = 0.964503, b = 0.014306], 
                  [r = 0.008437, g = 0.054813, b = 0.936750]
                }
              )
            ], 
            [
              Severity = 0.2, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.734766, g = 0.334872, b = - 0.069637], 
                  [r = 0.051840, g = 0.919198, b = 0.028963], 
                  [r = - 0.004928, g = - 0.004209, b = 1.009137]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.760729, g = 0.319078, b = - 0.079807], 
                  [r = 0.090568, g = 0.889315, b = 0.020117], 
                  [r = - 0.006027, g = 0.013325, b = 0.992702]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 0.895720, g = 0.133330, b = - 0.029050], 
                  [r = 0.029997, g = 0.945400, b = 0.024603], 
                  [r = 0.013027, g = 0.104707, b = 0.882266]
                }
              )
            ], 
            [
              Severity = 0.3, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.630323, g = 0.465641, b = - 0.095964], 
                  [r = 0.069181, g = 0.890046, b = 0.040773], 
                  [r = - 0.006308, g = - 0.007724, b = 1.014032]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.675425, g = 0.433850, b = - 0.109275], 
                  [r = 0.125303, g = 0.847755, b = 0.026942], 
                  [r = - 0.007950, g = 0.018572, b = 0.989378]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 0.905871, g = 0.127791, b = - 0.033662], 
                  [r = 0.026856, g = 0.941251, b = 0.031893], 
                  [r = 0.013410, g = 0.148296, b = 0.838294]
                }
              )
            ], 
            [
              Severity = 0.4, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.539009, g = 0.579343, b = - 0.118352], 
                  [r = 0.082546, g = 0.866121, b = 0.051332], 
                  [r = - 0.007136, g = - 0.011959, b = 1.019095]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.605511, g = 0.528560, b = - 0.134071], 
                  [r = 0.155318, g = 0.812366, b = 0.032316], 
                  [r = - 0.009376, g = 0.023176, b = 0.986200]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 0.948035, g = 0.089490, b = - 0.037526], 
                  [r = 0.014364, g = 0.946792, b = 0.038844], 
                  [r = 0.010853, g = 0.193991, b = 0.795156]
                }
              )
            ], 
            [
              Severity = 0.5, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.458064, g = 0.679578, b = - 0.137642], 
                  [r = 0.092785, g = 0.846313, b = 0.060902], 
                  [r = - 0.007494, g = - 0.016807, b = 1.024301]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.547494, g = 0.607765, b = - 0.155259], 
                  [r = 0.181692, g = 0.781742, b = 0.036566], 
                  [r = - 0.010410, g = 0.027275, b = 0.983136]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.017277, g = 0.027029, b = - 0.044306], 
                  [r = - 0.006113, g = 0.958479, b = 0.047634], 
                  [r = 0.006379, g = 0.248708, b = 0.744913]
                }
              )
            ], 
            [
              Severity = 0.6, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.385450, g = 0.769005, b = - 0.154455], 
                  [r = 0.100526, g = 0.829802, b = 0.069673], 
                  [r = - 0.007442, g = - 0.022190, b = 1.029632]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.498864, g = 0.674741, b = - 0.173604], 
                  [r = 0.205199, g = 0.754872, b = 0.039929], 
                  [r = - 0.011131, g = 0.030969, b = 0.980162]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.104996, g = - 0.046633, b = - 0.058363], 
                  [r = - 0.032137, g = 0.971635, b = 0.060503], 
                  [r = 0.001336, g = 0.317922, b = 0.680742]
                }
              )
            ], 
            [
              Severity = 0.7, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.319627, g = 0.849633, b = - 0.169261], 
                  [r = 0.106241, g = 0.815969, b = 0.077790], 
                  [r = - 0.007025, g = - 0.028051, b = 1.035076]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.457771, g = 0.731899, b = - 0.189670], 
                  [r = 0.226409, g = 0.731012, b = 0.042579], 
                  [r = - 0.011595, g = 0.034333, b = 0.977261]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.193214, g = - 0.109812, b = - 0.083402], 
                  [r = - 0.058496, g = 0.979410, b = 0.079086], 
                  [r = - 0.002346, g = 0.403492, b = 0.598854]
                }
              )
            ], 
            [
              Severity = 0.8, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.259411, g = 0.923008, b = - 0.182420], 
                  [r = 0.110296, g = 0.804340, b = 0.085364], 
                  [r = - 0.006276, g = - 0.034346, b = 1.040622]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.422823, g = 0.781057, b = - 0.203881], 
                  [r = 0.245752, g = 0.709602, b = 0.044646], 
                  [r = - 0.011843, g = 0.037423, b = 0.974421]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.257728, g = - 0.139648, b = - 0.118081], 
                  [r = - 0.078003, g = 0.975409, b = 0.102594], 
                  [r = - 0.003316, g = 0.501214, b = 0.502102]
                }
              )
            ], 
            [
              Severity = 0.9, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.203876, g = 0.990338, b = - 0.194214], 
                  [r = 0.112975, g = 0.794542, b = 0.092483], 
                  [r = - 0.005222, g = - 0.041043, b = 1.046265]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.392952, g = 0.823610, b = - 0.216562], 
                  [r = 0.263559, g = 0.690210, b = 0.046232], 
                  [r = - 0.011910, g = 0.040281, b = 0.971630]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.278864, g = - 0.125333, b = - 0.153531], 
                  [r = - 0.084748, g = 0.957674, b = 0.127074], 
                  [r = - 0.000989, g = 0.601151, b = 0.399838]
                }
              )
            ], 
            [
              Severity = 1.0, 
              Protanomaly = Table.FromRecords(
                {
                  [r = 0.152286, g = 1.052583, b = - 0.204868], 
                  [r = 0.114503, g = 0.786281, b = 0.099216], 
                  [r = - 0.003882, g = - 0.048116, b = 1.051998]
                }
              ), 
              Deuteranomaly = Table.FromRecords(
                {
                  [r = 0.367322, g = 0.860646, b = - 0.227968], 
                  [r = 0.280085, g = 0.672501, b = 0.047413], 
                  [r = - 0.011820, g = 0.042940, b = 0.968881]
                }
              ), 
              Tritanomaly = Table.FromRecords(
                {
                  [r = 1.255528, g = - 0.076749, b = - 0.178779], 
                  [r = - 0.078411, g = 0.930809, b = 0.147602], 
                  [r = 0.004733, g = 0.691367, b = 0.303900]
                }
              )
            ]
          }
        ), 
        Pro = Table.AddColumn(
          tbl, 
          "P", 
          each 
            let
              r = List.Min(
                {
                  red
                    * [Protanomaly][r]{0} + green
                    * [Protanomaly][g]{0} + blue
                    * [Protanomaly][b]{0}, 
                  255
                }
              ), 
              g = List.Min(
                {
                  red
                    * [Protanomaly][r]{1} + green
                    * [Protanomaly][g]{1} + blue
                    * [Protanomaly][b]{1}, 
                  255
                }
              ), 
              b = List.Min(
                {
                  red
                    * [Protanomaly][r]{2} + green
                    * [Protanomaly][g]{2} + blue
                    * [Protanomaly][b]{2}, 
                  255
                }
              )
            in
              Text.Combine(
                {
                  Text.From(Number.RoundAwayFromZero(Number.Abs(r), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(g), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(b), 0))
                }, 
                ","
              )
        ), 
        Deu = Table.AddColumn(
          Pro, 
          "D", 
          each 
            let
              r = List.Min(
                {
                  red
                    * [Deuteranomaly][r]{0} + green
                    * [Deuteranomaly][g]{0} + blue
                    * [Deuteranomaly][b]{0}, 
                  255
                }
              ), 
              g = List.Min(
                {
                  red
                    * [Deuteranomaly][r]{1} + green
                    * [Deuteranomaly][g]{1} + blue
                    * [Deuteranomaly][b]{1}, 
                  255
                }
              ), 
              b = List.Min(
                {
                  red
                    * [Deuteranomaly][r]{2} + green
                    * [Deuteranomaly][g]{2} + blue
                    * [Deuteranomaly][b]{2}, 
                  255
                }
              )
            in
              Text.Combine(
                {
                  Text.From(Number.RoundAwayFromZero(Number.Abs(r), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(g), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(b), 0))
                }, 
                ","
              )
        ), 
        Tri = Table.AddColumn(
          Deu, 
          "T", 
          each 
            let
              r = List.Min(
                {
                  red
                    * [Tritanomaly][r]{0} + green
                    * [Tritanomaly][g]{0} + blue
                    * [Tritanomaly][b]{0}, 
                  255
                }
              ), 
              g = List.Min(
                {
                  red
                    * [Tritanomaly][r]{1} + green
                    * [Tritanomaly][g]{1} + blue
                    * [Tritanomaly][b]{1}, 
                  255
                }
              ), 
              b = List.Min(
                {
                  red
                    * [Tritanomaly][r]{2} + green
                    * [Tritanomaly][g]{2} + blue
                    * [Tritanomaly][b]{2}, 
                  255
                }
              )
            in
              Text.Combine(
                {
                  Text.From(Number.RoundAwayFromZero(Number.Abs(r), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(g), 0)), 
                  Text.From(Number.RoundAwayFromZero(Number.Abs(b), 0))
                }, 
                ","
              )
        ), 
        ColorBlind = Table.SelectColumns(Tri, {"Severity", "P", "D", "T"})
      in
        ColorBlind, 
    GetHex = (red as number, green as number, blue as number) =>
      let
        // Build the RGB list
        RGB = List.Combine({{"0" .. "9"}, {"A" .. "F"}}), 
        ConvertToHex = (r, g, b) =>
          let
            r1        = RGB{Number.IntegerDivide(r, 16)}, 
            r2        = RGB{Number.Mod(r, 16)}, 
            g1        = RGB{Number.IntegerDivide(g, 16)}, 
            g2        = RGB{Number.Mod(g, 16)}, 
            b1        = RGB{Number.IntegerDivide(b, 16)}, 
            b2        = RGB{Number.Mod(b, 16)}, 
            HexOutput = "#" & r1 & r2 & g1 & g2 & b1 & b2
          in
            HexOutput
      in
        ConvertToHex(red, green, blue), 
    // Process the split list from the input
    RGBValues = GetColor(SplitHex), 
    RGBList = Text.Split(RGBValues, ","), 
    ColorBlindTable = CheckColorBlind(
      Number.From(RGBList{0}), 
      Number.From(RGBList{1}), 
      Number.From(RGBList{2})
    ), 
    RowsToHex = Table.TransformColumns(
      ColorBlindTable, 
      {
        {
          "P", 
          each GetHex(
            Number.From(Text.Split(_, ","){0}), 
            Number.From(Text.Split(_, ","){1}), 
            Number.From(Text.Split(_, ","){2})
          )
        }, 
        {
          "D", 
          each GetHex(
            Number.From(Text.Split(_, ","){0}), 
            Number.From(Text.Split(_, ","){1}), 
            Number.From(Text.Split(_, ","){2})
          )
        }, 
        {
          "T", 
          each GetHex(
            Number.From(Text.Split(_, ","){0}), 
            Number.From(Text.Split(_, ","){1}), 
            Number.From(Text.Split(_, ","){2})
          )
        }
      }
    ), 
    Renames = Table.RenameColumns(
      RowsToHex, 
      {{"P", "Protanomaly"}, {"D", "Deuteranomaly"}, {"T", "Tritanomaly"}}
    ), 
    Output = Table.TransformColumnTypes(
      Renames, 
      {
        {"Severity", type number}, 
        {"Protanomaly", type text}, 
        {"Deuteranomaly", type text}, 
        {"Tritanomaly", type text}
      }
    )
  in
    Output),


fnType = type function (HEX as text) as table meta 
[Documentation.Name = "CheckColorBlind",
Documentation.LongDescription = "This function returns a table of results applying different levels of severity for protanomaly, deuteranomaly, and tritanomaly color blindness.",
Documentation.Examples = {
    [Description = "This provides a table of results for the color red.",
    Code = "CheckColorBlind(""#FF0000"")",
    Result="Severity#(tab)Protanomaly#(tab)Deuteranomaly#(tab)Tritanomaly#(lf)" &
            "------------------------------------------------------------#(lf)" &
            "0#(tab)#(tab)#FF0000#(tab)#(tab)#FF0000#(tab)#(tab)#FF0000#(lf)" &
            "0.1#(tab)#(tab)#DA0701#(tab)#(tab)#DD0D01#(tab)#(tab)#EC0502#(lf)" &
            "0.2#(tab)#(tab)#BB0D01#(tab)#(tab)#C21702#(tab)#(tab)#E40803#(lf)" &
            "0.3#(tab)#(tab)#A11202#(tab)#(tab)#AC2002#(tab)#(tab)#E70703#(lf)" &
            "0.4#(tab)#(tab)#891502#(tab)#(tab)#9A2802#(tab)#(tab)#F20403#(lf)" &
            "0.5#(tab)#(tab)#751802#(tab)#(tab)#8C2E03#(tab)#(tab)#FF0202#(lf)" &
            "0.6#(tab)#(tab)#621A02#(tab)#(tab)#7F3403#(tab)#(tab)#FF0800#(lf)" &
            "0.7#(tab)#(tab)#521B02#(tab)#(tab)#753A03#(tab)#(tab)#FF0F01#(lf)" &
            "0.8#(tab)#(tab)#421C02#(tab)#(tab)#6C3F03#(tab)#(tab)#FF1401#(lf)" &
            "0.9#(tab)#(tab)#341D01#(tab)#(tab)#644303#(tab)#(tab)#FF1600#(lf)" &
            "1#(tab)#(tab)#271D01#(tab)#(tab)#5E4703#(tab)#(tab)#FF1401#(lf)"]
}]
    in  
Value.ReplaceType(CheckColorBlind, fnType)
let 
    GetRGBValue = 

// Calculate RGB based on hex value
(HEX as text)=>

let 
    // Split strings into list by each character, convert to upper, remove hash
    Source = if HEX <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX), "#")) else "#000000",
    
    // Split the Source by each character
    SplitHex = Splitter.SplitTextByRepeatedLengths(1)(Source),

    GetColor = (hexlist)=>

        let 
            // Build the RGB list
            RGB = List.Combine({{"0".."9"},{"A".."F"}}),
            
            // Sub function to figure out RGB value
            GetRGB = (cval1, cval2)=>
            let 
                RGBVal = (Number.From(cval1) * 16)+ Number.From(cval2)
            in       
                RGBVal,
            
            
            // Get positions of each digit
            r = GetRGB(List.PositionOf(RGB,hexlist{0}), List.PositionOf(RGB, hexlist{1})),
            g = GetRGB(List.PositionOf(RGB, hexlist{2}), List.PositionOf(RGB, hexlist{3})),
            b = GetRGB(List.PositionOf(RGB,hexlist{4}), List.PositionOf(RGB,hexlist{5})),

            
            // Combine R,G,B hex values to one hex value
            FinalRGB = Text.Combine({Text.From(r), Text.From(g), Text.From(b)}, ",")
        in
            FinalRGB,
    
    // Process the split list from the input
    RGBValues = GetColor(SplitHex)

    in

RGBValues,
    
fnType = type function (HEX as text) as text meta
[Documentation.Name = "GetRGBValue",
Documentation.LongDescription = "This is a function that converts a hex code to RGB values.",
Documentation.Examples = {
    [Description = "This converts #FFFFFF to RGB.",
    Code = "GetRGBValue(""#FFFFFF"")",
    Result="255,255,255"]
}] 

    in  
Value.ReplaceType(GetRGBValue, fnType)
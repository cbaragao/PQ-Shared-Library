let CheckColorContrast = 

    (HEX1 as text, HEX2 as text) as text=>

let 
    // Split strings into list by each character, convert to upper, remove hash
    H1 = if HEX1 <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX1), "#")) else "#000000",
    H2 = if HEX2 <> "" then Text.Upper(Text.AfterDelimiter(Text.From(HEX2), "#")) else "#000000",
    
    // Split the Source by each character
    SplitHex1 = Splitter.SplitTextByRepeatedLengths(1)(H1),
    SplitHex2 = Splitter.SplitTextByRepeatedLengths(1)(H2),
    
    GetLuminance = (hexlist) => 
        // Nested let function to do all luminance calculations
        let 
                // Set exp constant
                exp= 2.4,
                
                // Build the RGB list
                RGB = List.Combine({{"0".."9"},{"A".."F"}}),

                //Get srgb sunfunction
                GetSRGB = (cval1, cval2)=>
                let 
                    SRGB = ((cval1 * 16)+ cval2)/255
                    in       
                SRGB,

                // Get final c values subfunction
                GetFinalColorVal = (srgb)=>
                    let   
                        colorval = if srgb <=0.03928 then srgb/12.92 else Number.Power(((srgb + 0.055)/1.055), exp)
                    in  
                        colorval,  

                r1 = List.PositionOf(RGB, hexlist{0}),
                r2 = List.PositionOf(RGB, hexlist{1}),
                g1 = List.PositionOf(RGB, hexlist{2}),
                g2 = List.PositionOf(RGB, hexlist{3}),
                b1 = List.PositionOf(RGB, hexlist{4}),
                b2 = List.PositionOf(RGB, hexlist{5}),

                // Calculate rsrgb, gsrgb, bsrgb
                rsrgb = GetSRGB(r1,r2),
                gsrgb = GetSRGB(g1,g2),
                bsrgb = GetSRGB(b1,b2),

                // Calculate r, g, b
                r = GetFinalColorVal(rsrgb),
                g = GetFinalColorVal(gsrgb),
                b = GetFinalColorVal(bsrgb),
    
                // Calculate luminance
                luminance = (0.2126 * r) + 
                            (0.7152 * g) + 
                            (0.0722 * b)
        in  
                luminance,

    // Determine contrast ratio
    l1 = GetLuminance(SplitHex1),
    l2 = GetLuminance(SplitHex2),

    cratio =  if l1 > l2 then (l1 + 0.05) / (l2 + 0.05) else (l2 + 0.05) / (l1 + 0.05),

    // Set min contrast
    min = 4.5,

    // Determine if it meets min
    contrast = if cratio >= min then "Enough Contrast" else "Not Enough Contrast"
   
in 
    contrast,


fnType = type function (HEX1 as text, HEX2 as text) as text meta 
[Documentation.Name = "CheckColorContrast",
Documentation.LongDescription = "This function checks if there is enough contrast between two hex codes.",
Documentation.Examples = {
    [Description = "This checks if there is enough contrast between white and black.",
    Code = "CheckColorContrast(""#FFFFFF"", ""#000000"")",
    Result="Enough Contrast"],
    [Description = "This checks if there is enough contrast between two shades of red.",
    Code = "CheckColorContrast(""#FF0000"", ""#FE0000"")",
    Result="Not Enough Contrast"]
}]
    in  
Value.ReplaceType(CheckColorContrast, fnType)
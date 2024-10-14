# Load the required .NET assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Web

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

$base64icon = "AAABAAEAICAAAAEAIACoEAAAFgAAACgAAAAgAAAAQAAAAAEAIAAAAAAAABAAAL8yAAC/MgAAAAAAAAAAAABAfRAAQ3sQAEF8ECpBfBCXQXwQ4UF8EPtBfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EPtBfBDiQXwQl0F8ECpDexAAQH0QAEF8EABBfBBAQXwQ0kF8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ0kF8EEBBfBAAQXwQK0F8ENFBfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ0UF8ECtBfBCXQXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQl0F8EOBBfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBDgQXwQ+kF8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EPpBfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/P3sO/z97Dv9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QHwP/z56DP9Aew7/QXwQ/0F8EP9BfBD/QXwQ/0F8EP8/ew3/PnoM/0F8EP96o1f/hatm/0N+E/9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0B7D/9RhyT/hKtl/1uOMf9Aew7/QXwQ/0F8EP9BfBD/QXwQ/2aWP/+buoH/ssqf/+zy6P+mwY//RX8V/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/PnoN/2yZRf/2+PP/h61o/z56C/9BfBD/QXwQ/z97Dv90n1D/5u7g/9jlz//W48v/9fjz/4arZv8/ew3/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP8+eg3/bJlF//b48/+MsG//Rn8W/0R+FP8/eg3/Rn8W/8bYuP/W48v/VIkn/02EH//I2br/1eLK/0yEHv9AfA//QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/z56Df9rmUX/9vn0/+Ps2//S4Mb/w9Wz/3iiVf9Wiyv/5+7h/63GmP8/ew3/PnoM/5+8hv/u9Or/XZA0/z97Dv9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/PnoN/2uZRf/2+fP/uc+o/4+yc//K2rz/6fDj/3mjV//o7+L/q8WV/z97Dv8+egz/m7qB//H17f9hkjj/P3sN/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP8+eg3/bJlF//X48/+DqWP/NHMA/3qjV//3+vX/hatm/9PhyP/D1rT/RH4T/0B7D/+2zaP/4OrY/1KIJf9Aew//QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/z56Df9rmUX/9vnz/7jOpv+NsXD/zNy//+jv4f9fkTb/kbN0//H27v+ux5n/p8OR//D17P+evIX/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/P3sN/2KTOf/M3L//0+HJ/9Thyf/D1rT/eKJV/0F8EP9HgBj/kLNz/87dwv/Q38T/mLh+/0qDHP9Aew//QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/Q30S/0mCGv9Jghr/SYIa/0R+FP8/ew7/QXwQ/0F8D/9Aew7/R4AX/0eBGP9Aew//QHwP/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwP/0F8D/9BfA//QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfA//QXwP/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ+kF8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EPpBfBDgQXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ4EF8EJdBfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBCXQXwQK0F8ENFBfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ0UF8ECtBfBAAQXwQQEF8ENJBfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8ENJBfBBAQXwQAEB9EABDexAAQXwQKkF8EJdBfBDiQXwQ+0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ/0F8EP9BfBD/QXwQ+0F8EOFBfBCXQXwQKkN7EABAfRAAwAAAA4AAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAcAAAAM="

#FUNCTIONS
# Define the FormatPQ function
function FormatPQ {
    param (
        [string]$code,
        [string]$resultType,
        [int]$lineWidth = 80,
        [int]$indentationLength = 2,
        [bool]$includeComments = $true,
        [bool]$surroundBracesWithWs = $false,
        [bool]$indentSectionMembers = $true,
        [int]$alignLineCommentsToPosition = 0,
        [string]$alignPairedLetExpressionsByEqual = "never",
        [string]$alignPairedRecordExpressionsByEqual = "never",
        [string]$indentation = "spaces",
        [string]$ws = " ",
        [string]$lineEnd = "`n"
    )

    # Craft the body for the request
    $body = @{
        code = $code
        resultType = $resultType
        lineWidth = $lineWidth
        indentationLength = $indentationLength
        includeComments = $includeComments
        surroundBracesWithWs = $surroundBracesWithWs
        indentSectionMembers = $indentSectionMembers
        alignLineCommentsToPosition = $alignLineCommentsToPosition
        alignPairedLetExpressionsByEqual = $alignPairedLetExpressionsByEqual
        alignPairedRecordExpressionsByEqual = $alignPairedRecordExpressionsByEqual
        indentation = $indentation
        ws = $ws
        lineEnd = $lineEnd
    } | ConvertTo-Json

    # Set the URL
    $url = "https://m-formatter.azurewebsites.net/api/v2"

    # Send the request
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    } catch {
        Write-Error "Error: $_"
        return
    }

    # Get the reformatted query
    $formattedQuery = $response.result -replace "\\r\\n", "`r`n"

    # Return the reformatted query
    return $formattedQuery
}


# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PQ Shared Library Lookup"
$form.Size = New-Object System.Drawing.Size(410, 280)
$form.StartPosition = "CenterScreen"


# Convert base64 string to byte array
$iconBytes = [Convert]::FromBase64String($base64icon)

# Create a memory stream from the byte array
$memoryStream = New-Object System.IO.MemoryStream(,$iconBytes)

# Create an icon from the memory stream
$icon = New-Object System.Drawing.Icon($memoryStream)

# Set the form icon
$form.Icon = $icon

# Create a listbox to display the file names
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 35)
$listBox.Size = New-Object System.Drawing.Size(350, 120)
$form.Controls.Add($listBox)

# Create a button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10, 160)
$button.Size = New-Object System.Drawing.Size(100, 30)
$button.Text = "Copy"
$form.Controls.Add($button)

# Event handler for button click with error handling
$button.Add_Click({
    if ($listBox.SelectedItem) {
        try {
            $fileContent = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/cbaragao/PQ-Shared-Library/main/$($listBox.SelectedItem)"
            $selectedItem = $listBox.SelectedItem
            $parsedValue = ($selectedItem -split '/')[($selectedItem -split '/').Length - 1] -replace '\.pq$', ''
            $fileContent = "// $parsedValue`n$fileContent"
            Set-Clipboard -Value $fileContent
            [System.Windows.Forms.MessageBox]::Show("File content copied to clipboard.")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred while copying the file content.")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select a file from the list.")
    }
})



# Create a button to open the wiki
$wikiButton = New-Object System.Windows.Forms.Button
$wikiButton.Location = New-Object System.Drawing.Point(120, 160)
$wikiButton.Size = New-Object System.Drawing.Size(100, 30)
$wikiButton.Text = "Open Wiki"
$form.Controls.Add($wikiButton)

# Event handler for wiki button click
$wikiButton.Add_Click({
    Start-Process "https://github.com/cbaragao/PQ-Shared-Library/wiki"
})

# Get the list of .pq files from the repository
$repoUrl = "https://api.github.com/repos/cbaragao/PQ-Shared-Library/git/trees/main?recursive=1"
$files = Invoke-RestMethod -Uri $repoUrl

# Extract the path and url attributes from the $file.tree json object
$filePaths = $files.tree | ForEach-Object {
    [PSCustomObject]@{
        Path = $_.path
        Url = $_.url
    }
}

# Filter on path attributes that end in .pq
$pqFiles = $filePaths | Where-Object { $_.Path -like "*.pq" }

# Add the file names to the listbox
$listBox.Items.AddRange($pqFiles.Path)

# Create a textbox for search
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(10, 10)
$searchBox.Size = New-Object System.Drawing.Size(350, 20)
$form.Controls.Add($searchBox)

# Event handler for search box text change with error handling
$searchBox.Add_TextChanged({
    $searchText = $searchBox.Text
    $filteredFiles = $pqFiles | Where-Object { $_.Path -like "*$searchText*" }
    $listBox.Items.Clear()
    if ($filteredFiles) {
        $listBox.Items.AddRange($filteredFiles.Path)
    } else {
    }
})

# Set button colors
$button.BackColor = [System.Drawing.Color]::Green
$button.ForeColor = [System.Drawing.Color]::White

$wikiButton.BackColor = [System.Drawing.Color]::Green
$wikiButton.ForeColor = [System.Drawing.Color]::White

# Set form background color to white
$form.BackColor = [System.Drawing.Color]::White

$form.Add_Closing({param($sender,$e)
    $result = [System.Windows.Forms.MessageBox]::Show(`
        "Are you sure you want to exit?", `
        "Close", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        $e.Cancel= $true
    }
})

# Create tab control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Size = New-Object System.Drawing.Size(370, 220)
$tabControl.Location = New-Object System.Drawing.Point(10, 10)

# Create the first tab page
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Library"

# Create the second tab page
$tabPage2 = New-Object System.Windows.Forms.TabPage
$tabPage2.Text = "Format"

# Add controls to the first tab page
$tabPage1.Controls.Add($listBox)
$tabPage1.Controls.Add($button)
$tabPage1.Controls.Add($wikiButton)
$tabPage1.Controls.Add($searchBox)

# Add tab pages to the tab control
$tabControl.TabPages.Add($tabPage1)
$tabControl.TabPages.Add($tabPage2)

# Add the tab control to the form
$form.Controls.Add($tabControl)

# Create a textbox for the second tab page
$formatTextBox = New-Object System.Windows.Forms.TextBox
$formatTextBox.Location = New-Object System.Drawing.Point(10, 10)
$formatTextBox.Size = New-Object System.Drawing.Size(350, 140)
$formatTextBox.Multiline = $true
$tabPage2.Controls.Add($formatTextBox)

# Create a button for the second tab page
$formatButton = New-Object System.Windows.Forms.Button
$formatButton.Location = New-Object System.Drawing.Point(10, 160)
$formatButton.Size = New-Object System.Drawing.Size(100, 30)
$formatButton.Text = "Format"
$tabPage2.Controls.Add($formatButton)

$formatButton.BackColor = [System.Drawing.Color]::Green
$formatButton.ForeColor = [System.Drawing.Color]::White

# Event handler for format button click
$formatButton.Add_Click({
    $code = $formatTextBox.Text
    $resultType = "text" # Adjust as needed
    $formattedCode = FormatPQ -code $code -resultType $resultType
    $formatTextBox.Text = $formattedCode
    Write-Host $formattedCode
})

# Create a button to copy formatted code to clipboard
$copyFormatButton = New-Object System.Windows.Forms.Button
$copyFormatButton.Location = New-Object System.Drawing.Point(120, 160)
$copyFormatButton.Size = New-Object System.Drawing.Size(100, 30)
$copyFormatButton.Text = "Copy"

$copyFormatButton.BackColor = [System.Drawing.Color]::Green
$copyFormatButton.ForeColor = [System.Drawing.Color]::White

$tabPage2.Controls.Add($copyFormatButton)

# Create the third tab page
$tabPage3 = New-Object System.Windows.Forms.TabPage
$tabPage3.Text = "PQ How"

# Create a button for the third tab page
$pqHowButton = New-Object System.Windows.Forms.Button
$pqHowButton.Location = New-Object System.Drawing.Point(10, 10)
$pqHowButton.Size = New-Object System.Drawing.Size(100, 30)
$pqHowButton.Text = "Go to PQ How"

$pqHowButton.BackColor = [System.Drawing.Color]::Green
$pqHowButton.ForeColor = [System.Drawing.Color]::White

$tabPage3.Controls.Add($pqHowButton)

# Event handler for PQ How button click
$pqHowButton.Add_Click({
    Start-Process "https://powerquery.how"
})

# Add the third tab page to the tab control
$tabControl.TabPages.Add($tabPage3)

# Event handler for copy button click
$copyFormatButton.Add_Click({
    $formattedCode = $formatTextBox.Text
    Set-Clipboard -Value $formattedCode
    [System.Windows.Forms.MessageBox]::Show("Formatted code copied to clipboard.")
})

# Create the fourth tab page
$tabPage4 = New-Object System.Windows.Forms.TabPage
$tabPage4.Text = "VS Code"

# Create a button for the fourth tab page
$vsCodeButton = New-Object System.Windows.Forms.Button
$vsCodeButton.Location = New-Object System.Drawing.Point(10, 10)
$vsCodeButton.Size = New-Object System.Drawing.Size(150, 30)
$vsCodeButton.Text = "Open VS Code"

$vsCodeButton.BackColor = [System.Drawing.Color]::Green
$vsCodeButton.ForeColor = [System.Drawing.Color]::White

$tabPage4.Controls.Add($vsCodeButton)

# Event handler for VS Code button click
$vsCodeButton.Add_Click({
    try {
        Start-Process "code"
    } catch {
        $result = [System.Windows.Forms.MessageBox]::Show("Visual Studio Code is not installed or not in PATH. Would you like to download it?", "VS Code Not Found", [System.Windows.Forms.MessageBoxButtons]::YesNo)
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            Start-Process "https://code.visualstudio.com/"
        }
    }
})

# Add the fourth tab page to the tab control
$tabControl.TabPages.Add($tabPage4)

# Show the form
$form.ShowDialog() | Out-Null
$form.Dispose()


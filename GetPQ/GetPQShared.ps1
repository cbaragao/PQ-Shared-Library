Add-Type -AssemblyName System.Windows.Forms

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PQ Shared Library Lookup"
$form.Size = New-Object System.Drawing.Size(390, 250)
$form.StartPosition = "CenterScreen"



#$iconPath = "GetPQ\assets\pqshared.ico"
#$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)

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
$wikiButton.Location = New-Object System.Drawing.Point(250, 160)
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

# Show the form
$form.ShowDialog() | Out-Null
$form.Dispose()


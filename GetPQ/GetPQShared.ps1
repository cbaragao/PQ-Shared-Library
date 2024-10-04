Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PQ File Selector"
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = "CenterScreen"

# Create a listbox to display the file names
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 10)
$listBox.Size = New-Object System.Drawing.Size(380, 120)
$form.Controls.Add($listBox)

# Create a button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10, 140)
$button.Size = New-Object System.Drawing.Size(100, 50)
$button.Text = "Copy to Clipboard"
$form.Controls.Add($button)

# Event handler for button click
$button.Add_Click({
    if ($listBox.SelectedItem) {
        $fileContent = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/cbaragao/PQ-Shared-Library/main/$($listBox.SelectedItem)"
        Set-Clipboard -Value $fileContent
        [System.Windows.Forms.MessageBox]::Show("File content copied to clipboard.")
    }
})

# Create a button to open the wiki
$wikiButton = New-Object System.Windows.Forms.Button
$wikiButton.Location = New-Object System.Drawing.Point(275, 140)
$wikiButton.Size = New-Object System.Drawing.Size(100, 50)
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
# Show the form
$form.ShowDialog()
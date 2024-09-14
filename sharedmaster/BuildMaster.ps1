# Define the root directory

$rootDir = "..\functions"

# Initialize an array to hold the records
$records = @()

# Loop through each .pq file in the directory and subdirectories
Get-ChildItem -Path $rootDir -Recurse -Filter *.pq | ForEach-Object {
    $filePath = $_.FullName
    $fileName = $_.BaseName
    $subDirName = $_.Directory.Name
    $fileContent = Get-Content -Path $filePath -Raw


    # Add the record to the array
    $records += @"
      [
        Name = `"$fileName`", 
        Category = `"$subDirName`", 
        Function = 
          $fileContent 
      ]
"@
}

# Concatenate the records
$concatRecords = $records -join ",`n"

# Create the template with the concatenated records
$template = @"
let
  return = Table.FromRecords(
    {
$concatRecords
    },
    type table [Name = Text.Type, Category = Text.Type, Function = Function.Type]
  )
in
  return
"@

# Output the template to a file
$template | Out-File -FilePath ".\SharedMaster.pq" -Force


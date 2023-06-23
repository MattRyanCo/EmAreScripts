$prodFile = C:\Users\EmAre\Documents\CampbellsNotes\csc-websites-prod.txt"
$devFile = C:\Users\EmAre\Documents\CampbellsNotes\csc-websites-dev.txt"
$stageFile = C:\Users\EmAre\Documents\CampbellsNotes\csc-websites-stage.txt"

# Grab initial set of dev and stage terms
cat csc-websites.txt | findstr  "dev" > $devFile
cat csc-websites.txt | findstr  "stag" > $stageFile

# A little fine tuning
cat csc-websites.txt | findstr  "temp" >> $devFile
cat csc-websites.txt | findstr  "tmp" >> $devFile
cat csc-websites.txt | findstr  "stg" >> $stageFile

# Read the contents of the dev and stage files
$devContent = Get-Content $devFile
$stageContent = Get-Content $stageFile

# Filter the lines from the source file that don't have a match in dev or stage files
$filteredContent = Get-Content C:\Users\EmAre\Documents\CampbellsNotes\csc-websites.txt" | Where-Object {
    $line = $_
    $matchingDev = $devContent | Where-Object { $_ -eq $line }
    $matchingStage = $stageContent | Where-Object { $_ -eq $line }
    -not $matchingDev -and -not $matchingStage
}

# Write the filtered lines to the prod file
$filteredContent | Set-Content $prodFile

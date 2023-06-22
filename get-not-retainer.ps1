$prodFile = C:\Users\EmAre\Documents\CampbellsNotes\csc-websites-prod.txt"
$devFile = C:\Users\EmAre\Documents\CampbellsNotes\csc-websites-dev.txt"
$stageFile = C:\Users\EmAre\Documents\CampbellsNotes\csc-websites-stage.txt"
$notOnRetainerFile = C:\Users\EmAre\Documents\CampbellsNotes\csc-websites-not-on-retainer.txt"

# Grab initial set of dev and stage terms
# cat csc-websites.txt | findstr  "dev" > $devFile
# cat csc-websites.txt | findstr  "stag" > $stageFile

# # A little fine tuning
# cat csc-websites.txt | findstr  "temp" >> $devFile
# cat csc-websites.txt | findstr  "tmp" >> $devFile
# cat csc-websites.txt | findstr  "stg" >> $stageFile

# Read the contents of the dev and stage files
$devContent = Get-Content $devFile
$stageContent = Get-Content $stageFile
$prodContent = Get-Content $prodFile

# Filter the lines from the source file that don't have a match in dev, stage or prod files
$filteredContent = Get-Content C:\Users\EmAre\Documents\CampbellsNotes\csc-websites.txt" | Where-Object {
    $line = $_
    $matchingDev = $devContent | Where-Object { $_ -eq $line }
    $matchingStage = $stageContent | Where-Object { $_ -eq $line }
    # $matchingProd = $prodContent | Where-Object { $_ -eq $line }
    # -not $matchingDev -and -not $matchingStage -and -not $matchingProd
    -not $matchingDev -and -not $matchingStage
}
Write-Host $filteredContent
Write-Host "------------------------------------------------------------"


# Filter the lines from the source file that don't have a match in dev, stage or prod files
$filteredContent2 = Get-Content C:\Users\EmAre\Documents\CampbellsNotes\csc-websites.txt" | Where-Object {
    $line = $_
    # $matchingStage = $stageContent | Where-Object { $_ -eq $line }
    $matchingProd = $prodContent | Where-Object { $_ -eq $line }
    -not $matchingProd
}
Write-Host $filteredContent2

# Write the filtered lines to the NotOnRetainer file
$filteredContent | Set-Content $notOnRetainerFile

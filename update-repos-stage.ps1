# Define the list of repository names
$repositoryNames = @(
    "pfw-wp-v8-composer",
    "pfw-wp-swanson-composer",
    "pfw-wp-pace-composer"
    "pfw-wp-swanson-composer"
    "pfw-wp-campbells-composer"
    "pfw-wp-prego-composer"
    # Add more repository names to the list
)

# Specify the local repository folder path
$localRepoFolder = "C:\Users\EmAre\LocalRepos"

foreach ($repoName in $repositoryNames) {
    # Change into the repository folder
    $repoFolderPath = Join-Path -Path $localRepoFolder -ChildPath $repoName
    Set-Location $repoFolderPath

    # Pull down the stage branch
    git pull origin stage -f

    # Checkout a new branch
    $newBranchName = "ticket/WS-1640-update-name-of-nfp-title-stage"
    git checkout -b $newBranchName

    # Run the composer require command
    $composerCommand = "composer require campbellsoupco/v8-child-theme:dev-stage"
    Invoke-Expression $composerCommand

    # Set-Location $localRepoFolder

    Write-Host "Completed processing repository: $repoName"
    Write-Host "------------------------------------------------------------"
}

Write-Host "Script execution completed."

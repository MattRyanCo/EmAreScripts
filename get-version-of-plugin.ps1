param (
    [string]$plugin = "advanced-custom-fields-pro",
    [string]$websitesFile = C:\Users\EmAre\Documents\CampbellsNotes\csc-websites-dev-retainer.txt"
)
BEGIN {
    $prefBackup = $WarningPreference
    $WarningPreference = 'SilentlyContinue'
}


PROCESS {
    # Start the transcription log. 

    Write-Host $($MyInvocation.MyCommand.Name)
    Start-Transcript -Path versions.log
    Get-Date
    $ErrorActionPreference = "Stop"

    if (-not (Test-Path -Path $websitesFile)) {
        Write-Host "File not found: $websitesFile"
        Stop-Transcript
        exit 1
    }

    # Read the list of websites from the text file
    $websites = Get-Content -Path $websitesFile

    # Read the list of websites from the text file if singleWebsite parameter is not provided
    if (![string]::IsNullOrWhiteSpace($singleWebsite)) {
        $websites = $singleWebsite.Trim()
    }

    # Loop through all websites or just the one provided. 
    foreach ($website in $websites) {
        $website = $website.Trim()  # Remove any leading or trailing whitespace
        
        Write-Host "Accessing $website@$website.ssh.wpengine.net via SSH."
        Get-Date
        
        $sshCommand = "ssh $website@$website.ssh.wpengine.net  -o StrictHostKeyChecking=no "
        $checkPluginVersionCommand = "wp plugin get advanced-custom-fields-pro   --field=version"

        Invoke-Expression "$sshCommand $checkPluginVersionCommand"
        $pluginVersion = $?

        # returns 0 if installed, 1 if not.
        # $checkPluginCommand = "wp plugin is-installed advanced-custom-fields-pro"
        # $checkWPVersionCommand = "wp core version"

        # $updatePluginCommand = "wp plugin update advanced-custom-fields-pro"

        # SSH and check if the plugin is installed
        # Invoke-Expression "$sshCommand $checkPluginCommand"
        # $isInstalled = $?
        
        # Write-Host "$website WP version is "
        # Invoke-Expression "$sshCommand $checkWPVersionCommand"
        
        # if ($isInstalled -eq "0") {

        #     # Set license key for update
        #     $isInvoked = Invoke-Expression "$sshCommand $addAcfLicenseKeyCommand"
        #     $isInvoked = $?
        #     if ( !$isInvoked ) {
        #         Write-Host "ACF key addition on $website failed."
        #     }

        #     Invoke-Expression "$sshCommand $checkPluginVersionCommand"
        #     $pluginVersion = $?

        #     # Run the update plugin command
        #     Write-Host "Updating plugin on $website."
        #     Invoke-Expression "$sshCommand $updatePluginCommand"
        #     Write-Host "Plugin updated successfully on $website."
        #     Write-Host "Plugin updated successfully on $website." | Out-File -FilePath C:\Users\EmAre\Documents\CampbellsNotes\update-acfpro-success.txt

        # }
        # else {
        #     Write-Host "Plugin not installed on $website. Next."
        # }
        
        Write-Host "------------------------------------------------------------"
    }


    Write-Host "Script execution completed."
    Get-Date
    Stop-Transcript
}
END {
    $WarningPreference = $prefBackup
}

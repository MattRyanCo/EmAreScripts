param (
    [string]$singleWebsite,
    [string]$environmentWebsiteList,
    [string]$websitesFile = C:\Users\EmAre\Documents\CampbellsNotes\csc-websites-dev-retainer.txt"
)
BEGIN {
    $prefBackup = $WarningPreference
    $WarningPreference = 'SilentlyContinue'
}


PROCESS {
    # Start the transcription log. 

    Start-Transcript -Path update-acfpro.log
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

    # Set license key addition & removal commands for ACF Pro
    $addAcfLicenseKeyCommand = "wp config set ACF_PRO_LICENSE b3JkZXJfaWQ9ODY3OTh8dHlwZT1kZXZlbG9wZXJ8ZGF0ZT0yMDE2LTA4LTAyIDEzOjA5OjMy --anchor=EOF --quiet"
    $removeAcfLicenseKeyCommand = "wp config delete ACF_PRO_LICENSE"

    # Loop through all websites or just the one provided. 
    foreach ($website in $websites) {
        $website = $website.Trim()  # Remove any leading or trailing whitespace
        
        Write-Host "Accessing $website@$website.ssh.wpengine.net via SSH."
        Get-Date
        
        $sshCommand = "ssh $website@$website.ssh.wpengine.net  -o StrictHostKeyChecking=no"

        # returns 0 if installed, 1 if not.
        $checkPluginCommand = "wp plugin is-installed advanced-custom-fields-pro"
        $checkWPVersionCommand = "wp core version"
        $checkPluginVersionCommand = "wp plugin get advanced-custom-fields-pro   --field=version"
        $updatePluginCommand = "wp plugin update advanced-custom-fields-pro"

        # SSH and check if the plugin is installed
        Invoke-Expression "$sshCommand $checkPluginCommand"
        $isInstalled = $?
        
        Write-Host "$website WP version is "
        Invoke-Expression "$sshCommand $checkWPVersionCommand"
        
        if ($isInstalled -eq "0") {

            # Set license key for update
            $isInvoked = Invoke-Expression "$sshCommand $addAcfLicenseKeyCommand"
            $isInvoked = $?
            if ( !$isInvoked ) {
                Write-Host "ACF key addition on $website failed."
            }

            Invoke-Expression "$sshCommand $checkPluginVersionCommand"
            $pluginVersion = $?

            # Run the update plugin command
            Write-Host "Updating plugin on $website."
            Invoke-Expression "$sshCommand $updatePluginCommand"
            Write-Host "Plugin updated successfully on $website."
            Write-Host "Plugin updated successfully on $website." | Out-File -FilePath .\update-acfpro-success.txt

        }
        else {
            Write-Host "Plugin not installed on $website. Next."
        }
        
        Write-Host "------------------------------------------------------------"
    }


    Write-Host "Script execution completed."
    Get-Date
    Stop-Transcript
}
END {
    $WarningPreference = $prefBackup
}

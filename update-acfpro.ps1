param (
    [string]$singleWebsite,
    [string]$environmentWebsiteList
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

    # Default list of WPE environment to process. 
    if ([string]::IsNullOrWhiteSpace($environmentWebsiteList)) {
        $websitesFile = "csc-websites.txt"
    }
    else {
        $websitesFile = $environmentWebsiteList.Trim()
    }

    # Read the list of websites from the text file if singleWebsite parameter is not provided
    if ([string]::IsNullOrWhiteSpace($singleWebsite)) {
        
        # if the list of WPE environments is found, read the contents. 
        if ( Test-Path $websitesFile ) {
            $websites = Get-Content $websitesFile
        }
        else {
            # List of WPE environments not found. Exiting. 
            Write-Host "$websitesFile input file not found."
            Stop-Transcript
            exit 1
        }
    }
    else {
        $websites = $singleWebsite.Trim()
    }

    # Static commands. 
    # Set command to check of plug is installed. 
    $checkPluginCommand = "wp plugin is-installed advanced-custom-fields-pro"

    # Set license key addition & removal commands for ACF Pro
    $addAcfLicenseKeyCommand = "wp config set ACF_PRO_LICENSE b3JkZXJfaWQ9ODY3OTh8dHlwZT1kZXZlbG9wZXJ8ZGF0ZT0yMDE2LTA4LTAyIDEzOjA5OjMy --anchor=EOF --quiet"
    $removeAcfLicenseKeyCommand = "wp config delete ACF_PRO_LICENSE"

    # Actual command to do plugin update. 
    $updatePluginCommand = "wp plugin update advanced-custom-fields-pro"

    # Loop through all websites or just the one provided. 
    foreach ($website in $websites) {
        $website = $website.Trim()  # Remove any leading or trailing whitespace
        
        if (-not [string]::IsNullOrWhiteSpace($website)) {
            # Log each website being processed. 
            Write-Host "Accessing $website@$website.ssh.wpengine.net via SSH..."
            Get-Date
            
            # Set primary ssh access command/ Turn off hostkey checking prompt. 
            $sshCommand = "ssh $website@$website.ssh.wpengine.net  -o StrictHostKeyChecking=no"

            # SSH and check if the plugin is installed
            $isInstalled = Invoke-Expression "$sshCommand $checkPluginCommand"
            $isInstalled = $?   # Assign return code to variable for conditional.
            
            if ($isInstalled) {
                # Set license key for update
                $isInvoked = Invoke-Expression "$sshCommand $addAcfLicenseKeyCommand"
                $isInvoked = $?
                if ( !$isInvoked ) {
                    Write-Host "ACF key addition on $website failed."
                }

                # Run the update plugin command
                Write-Host "Updating plugin on $website..."
                $isInvoked = Invoke-Expression "$sshCommand $updatePluginCommand"
                $isInvoked = $?
                if ( $isInvoked ) {
                    Write-Host "Plugin updated on $website."
                    Write-Host $website | Out-File -FilePath .\update-acfpro-success.txt
                }
                else {
                    Write-Host "Plugin update on $website failed." 
                }

                # Remove license key for ACF Pro from wp-config
                $isInvoked = Invoke-Expression "$sshCommand $removeAcfLicenseKeyCommand"
                $isInvoked = $?
                if ( !$isInvoked ) {
                    Write-Host "ACF key removal on $website failed."
                }
            }
            else {
                Write-Host "Plugin not installed on $website. Skipping..."
            }
            
            Write-Host "------------------------------------------------------------"
        }
    }
    Write-Host "Script execution completed."
    Get-Date
    Stop-Transcript
}
END {
    $WarningPreference = $prefBackup
}

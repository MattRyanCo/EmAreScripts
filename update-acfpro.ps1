$websitesFile = "csc-websites.txt"

# Read the list of websites from the text file
$websites = Get-Content $websitesFile

foreach ($website in $websites) {
    $website = $website.Trim()  # Remove any leading or trailing whitespace
    
    if (-not [string]::IsNullOrWhiteSpace($website)) {
        Write-Host "Accessing $website@$website.ssh.wpengine.net via SSH..."
        
        $sshCommand = "ssh $website@$website.ssh.wpengine.net  -o StrictHostKeyChecking=no"
        # $changeFolderCommand = "cd /var/www/html/sites"
        $checkPluginCommand = "wp plugin is-installed advanced-custom-fields-pro"
        # returns 0 if installed, 1 if not.

        $updatePluginCommand = "wp plugin update advanced-custom-fields-pro"

        # SSH and check if the plugin is installed
        $isInstalled = Invoke-Expression "$sshCommand $checkPluginCommand"
        # 
        # The above generates a reply for adding the host key that is: 
        # Are you sure you want to continue connecting (yes/no/[fingerprint])?
        
        if ($isInstalled -eq "Success") {
            # if ($isInstalled -eq "0") {
            Write-Host "Updating plugin on $website..."
            # Run the update plugin command
            # Invoke-Expression "$sshCommand $updatePluginCommand"
            Write-Host "Plugin updated successfully."
        }
        else {
            Write-Host "Plugin not installed on $website. Skipping..."
        }
        
        Write-Host "------------------------------------------------------------"
    }
}

Write-Host "Script execution completed."

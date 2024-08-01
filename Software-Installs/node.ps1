function ManageNodeJsInstallation {
    $TargetVersion = "v18.19.1"
    $InstallerPath = "$env:USERPROFILE\Downloads\node-v18.19.1-x64.msi"

    # Helper function to get the currently installed Node.js version
    function Get-InstalledNodeVersion {
        try {
            $versionOutput = & node --version 2>&1
            return $versionOutput.Trim()
        } catch {
            return $null
        }
    }

    # Check the currently installed Node.js version
    $installedVersion = Get-InstalledNodeVersion

    # Uninstall Node.js if installed version is not the target version
    if ($installedVersion -and $installedVersion -ne $TargetVersion) {
        $productCode = (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Node.js*" } | Select-Object -ExpandProperty IdentifyingNumber).ToString()
        if ($productCode) {
            Write-Host "Uninstalling Node.js version $installedVersion..."
            Start-Process msiexec.exe -ArgumentList "/x $productCode /qn" -Wait
            Write-Host "Uninstallation complete."
        } else {
            Write-Host "Failed to find Node.js product code. Manual uninstallation may be required."
        }
    }

    # Install Node.js version 18.19.1
    if (-not (Test-Path $InstallerPath)) {
        Write-Host "Downloading Node.js v18.19.1 installer..."
        (New-Object System.Net.WebClient).DownloadFile("https://nodejs.org/dist/v18.19.1/node-v18.19.1-x64.msi", $InstallerPath)
    }
    Write-Host "Installing Node.js v18.19.1..."
    Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" /qn" -Wait
    Write-Host "Node.js v18.19.1 installation complete."

    # Validate the installation
    $installedVersion = Get-InstalledNodeVersion
    if ($installedVersion -eq $TargetVersion) {
        Write-Host "Validation successful: Node.js v18.19.1 is correctly installed."
    } else {
        Write-Host "Validation failed: Node.js v18.19.1 is not installed correctly."
    }
}

# Execute the function
$ManageNodeJsInstallation
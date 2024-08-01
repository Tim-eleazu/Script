# Variables for easy updates and readability
$userPath = "C:\Users\prodops\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu22.04LTS_79rhkp1fndgsc"
$ubuntuVersion = "Ubuntu-22.04"
$waitTimeForInstallation = 30 # Time in seconds

# Checks the Ubuntu Installation Path
if (Test-Path $userPath) {
    Write-Host "Ubuntu is already installed."
} else {
    Write-Host "$ubuntuVersion is not installed. Installing now..."

        # Install Ubuntu
        wsl --install -d $ubuntuVersion
        Start-Sleep -Seconds $waitTimeForInstallation # Wait for the installation to initiate

        # Set Ubuntu to use WSL 2
        wsl --set-version $ubuntuVersion 2 
        
        Start-Sleep -Seconds $waitTimeForInstallation # Ensure the installation completes

        Write-Host "$ubuntuVersion installation and configuration to WSL 2 completed. The system will now restart to apply changes."

        # Restart the system immediately
        shutdown /r /t 10
}
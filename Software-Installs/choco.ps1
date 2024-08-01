# Function to check if Chocolatey is installed
function Is-ChocoInstalled {
    $chocoPath = Get-Command "choco" -ErrorAction SilentlyContinue
    return $chocoPath -ne $null
}

# Check if Chocolatey is installed
if (Is-ChocoInstalled) {
    Write-Host "Chocolatey is already installed."
    exit
} else {
    Write-Host "Chocolatey is not installed. Checking for installer..."

    # Define the path for the Chocolatey install script in the Downloads folder
    $chocoInstallScriptPath = "$env:USERPROFILE\Downloads\install.ps1"

    # Check if the installer script is in the Downloads folder
    if (Test-Path $chocoInstallScriptPath) {
        Write-Host "Found Chocolatey install script in Downloads folder. Installing Chocolatey..."
        # Run the installer script from the Downloads folder
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString($chocoInstallScriptPath))
    } else {
        Write-Host "Downloading Chocolatey install script..."
        # Download and install Chocolatey
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    Write-Host "Chocolatey installation complete."
    exit
}
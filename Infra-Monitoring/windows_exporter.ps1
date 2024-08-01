# PowerShell script to check if windows_exporter service is running and install it if not

# Function to check if windows_exporter service is running
function Is-WindowsExporterServiceRunning {
    $service = Get-Service -Name "windows_exporter" -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        return $true
    } else {
        return $false
    }
}

# Check if windows_exporter service is running
if (Is-WindowsExporterServiceRunning) {
    Write-Output "windows_exporter service is already running."
} else {
    Write-Output "windows_exporter service is not running or not installed. Proceeding with installation..."

    # Specify the URL of the windows_exporter MSI package
    $msiUrl = "https://github.com/prometheus-community/windows_exporter/releases/download/v0.25.1/windows_exporter-0.25.1-amd64.msi"

    # Specify the path where the MSI will be downloaded
    $downloadPath = "$env:TEMP\windows_exporter-0.25.1-amd64.msi"

    # Download the MSI package
    Invoke-WebRequest -Uri $msiUrl -OutFile $downloadPath

    # Install the MSI package
    Start-Process "msiexec.exe" -ArgumentList "/i `"$downloadPath`" /qn" -Wait -NoNewWindow

    # Cleanup - Remove the MSI package after installation
    Remove-Item -Path $downloadPath -Force

    # Output success message
    Write-Output "windows_exporter has been successfully installed."
}
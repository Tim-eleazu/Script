# Function to check if Visual Studio 2019 is installed at the specified path
function Is-VisualStudio2019Installed {
    $installPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Microsoft"
    $installed = Test-Path $installPath
    return $installed
}

# Check if Visual Studio 2019 is installed
if (Is-VisualStudio2019Installed) {
    Write-Host "Visual Studio 2019 is already installed."
} else {
    Write-Host "Visual Studio 2019 not found. Proceeding with installation."

    # Define the source and destination paths
    $sourcePath = "\\192.168.1.102\Software\Microsoft\Visual Studio 2019 Professional\vs_professional__6e8b1400670b4ee38d539d9c177aeafc.exe"
    $destinationPath = "$env:USERPROFILE\Downloads\vs_professional__6e8b1400670b4ee38d539d9c177aeafc.exe"

    # Copy the installer from the network path to the local machine
    Copy-Item -Path $sourcePath -Destination $destinationPath -Force

    # Check if the file was copied successfully
    if (Test-Path $destinationPath) {
        Write-Host "Installer copied successfully to $destinationPath."
        
        # Define installer arguments
        $installerArgs = "--quiet --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools"

        Write-Host "Starting Visual Studio 2019 installation in silent mode."
        Start-Process -FilePath "$destinationPath" -ArgumentList $installerArgs -Wait -NoNewWindow

        Write-Host "Visual Studio 2019 installation command has been executed."
    } else {
        Write-Host "Failed to copy the installer."
    }
}

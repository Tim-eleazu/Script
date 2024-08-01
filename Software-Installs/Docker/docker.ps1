# Variables for paths
$installerUri = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
$downloadPath = "C:\Users\prodops\Downloads\DockerDesktopInstaller.exe" 

#Check If Docker Is Installed 
try {
    $dockerVersion = docker --version 
    Write-Host "Docker is installed. Version: $dockerVersion"
} catch {
    Write-Host "Docker is not installed, proceeding with Installation ....." 

    # # Download Docker Desktop Installer
    Invoke-WebRequest -Uri $installerUri -OutFile $downloadPath 

    # # Start Docker Desktop Installation
    Start-Process -FilePath $downloadPath -ArgumentList "install --quiet --accept-license --no-windows-containers --backend=wsl-2" -Wait

    Write-Host "Docker has been installed, Restarting in 10 seconds ...."
    #Restart the system 
    shutdown /r /t 10 
}
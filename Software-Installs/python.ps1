# Function to check if Python 3.10.11 is installed
function IsPython31011Installed {
    try {
        $output = & py -3.10 --version 2>&1
        return $output -like "*Python 3.10.11*"
    } catch {
        return $false
    }
}

# Check if Python 3.10.11 is installed
if (-not (IsPython31011Installed)) {
    Write-Host "Python 3.10.11 is not installed, proceeding with installation."

    # Python version
    $pythonVersion = "3.10.11"

    # Path to the Python installer in the Downloads folder
    $pythonInstallerPath = "$env:USERPROFILE\Downloads\python-3.10.11-amd64.exe"

    # Python download URL
    $pythonDownloadUrl = "https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe"

    # Downloading Python 3.10.11 installer
    Write-Host "Downloading Python $pythonVersion installer..." 

    #Command to Download the python Installer
    Invoke-WebRequest -Uri $pythonDownloadUrl -OutFile $pythonInstallerPath

    # Install Python
    Write-Host "Installing Python $pythonVersion..."
    $installPath = "C:\Program Files\Python310" 

    #Python Installation with specific Arguements
    Start-Process -FilePath $pythonInstallerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 TargetDir=`"$installPath`" Include_doc=1 Include_pip=1 Include_tcltk=1 Include_test=1 LauncherAllUsers=1 AssociateFiles=1 Shortcuts=1 Include_launcher=1 CompileAll=1" -Wait
    Write-Host "Python $pythonVersion installation complete."

    # Add Python to System Path Manually
    $PythonPath = "$installPath"
    $ScriptsPath = "$installPath\Scripts"
    $EnvPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if (-not $EnvPath.Contains($PythonPath)) {
        $NewPath = "$PythonPath;$ScriptsPath;" + $EnvPath
        [System.Environment]::SetEnvironmentVariable("Path", $NewPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Added Python to system PATH."
    } else {
        Write-Host "Python paths are already in system PATH."
    }

    # Check if Python was installed correctly in the path
    if (Test-Path "$installPath\python.exe") {
        Write-Host "Python $pythonVersion has been installed to $installPath."
    } else {
        Write-Host "Installation failed or Python was not installed to the expected directory."
    }

    # Disable Python Launcher Execution Alias
    $ExecAliasPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"
    if (Test-Path "$ExecAliasPath\python.exe") {
        Remove-Item "$ExecAliasPath\python.exe" -Force
        Write-Host "Disabled Python Launcher app execution alias."
    }
    if (Test-Path "$ExecAliasPath\python3.exe") {
        Remove-Item "$ExecAliasPath\python3.exe" -Force
        Write-Host "Disabled Python3 Launcher app execution alias."
    }
} else {
    Write-Host "Python 3.10.11 is already installed."
}
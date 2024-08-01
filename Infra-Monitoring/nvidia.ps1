# Check if nvidia_gpu_exporter service is installed
$service = Get-Service nvidia_gpu_exporter -ErrorAction SilentlyContinue
$program = Get-Command nvidia_gpu_exporter -ErrorAction SilentlyContinue

# If the service or program is not installed, proceed with installation and setup
if (-not $service -or -not $program) {
    # Set execution policy to allow scripts
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    
    # Create a new firewall rule to allow traffic
    New-NetFirewallRule -DisplayName "Nvidia GPU Exporter" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9835
    
    # Install Scoop with administrative privileges
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    
    # Install NSSM globally using Scoop with administrative privileges
    Start-Process powershell -ArgumentList "scoop install nssm --global" -Verb RunAs -Wait
    
    # Add the nvidia_gpu_exporter bucket to Scoop
    scoop bucket add nvidia_gpu_exporter https://github.com/utkuozdemir/scoop_nvidia_gpu_exporter.git
    
    # Install nvidia_gpu_exporter globally using Scoop with administrative privileges
    Start-Process powershell -ArgumentList "scoop install nvidia_gpu_exporter/nvidia_gpu_exporter --global" -Verb RunAs -Wait
    
    # Install nvidia_gpu_exporter as a service using NSSM
    nssm install nvidia_gpu_exporter "C:\ProgramData\scoop\apps\nvidia_gpu_exporter\current\nvidia_gpu_exporter.exe"
    
    # Start the nvidia_gpu_exporter service
    Start-Service nvidia_gpu_exporter
} else {
    Write-Host "nvidia_gpu_exporter is already installed and running."
}
# Define the URL for the CUDA binary and the destination path for the extracted files
$installerUrl = "https://developer.download.nvidia.com/compute/cuda/11.2.2/local_installers/cuda_11.2.2_461.33_win10.exe"
$destinationPath = "C:\CUDA" #Any Desstination of your choice

# Create the directory if it does not exist
if (-not (Test-Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}

# Download the CUDA installer
Write-Host "Downloading CUDA installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile "$destinationPath\cuda_installer.exe"

$arguments = "-s", "nvcc_11.2", "cusparse_11.2", "cublas_11.2", "cublas_dev_11.2", "cudart_11.2", "cusolver_11.2", "cusolver_dev_11.2", "cufft_11.2", "cufft_dev_11.2", "curand_11.2", "curand_dev_11.2", "cupti_11.2", "nvprune_11.2", "nvml_dev_11.2", "nvgraph_11.2", "npp_11.2", "npp_dev_11.2", "nsight_compute_11.2", "nsight_systems_11.2"

Write-Host "Starting CUDA installation..."
Start-Process -FilePath "$destinationPath\cuda_installer.exe" -ArgumentList $arguments -Wait -NoNewWindow

# Clean up the installer if no longer needed
Remove-Item "$destinationPath\cuda_installer.exe" -Force

Write-Host "CUDA installation completed."
# Target Node.js version to keep
$TargetVersion = "18.19.1"

function Get-NodeVersion {
    try {
        $output = & node --version 2>&1
        $output = $output -replace "v", ""
        return $output.Trim()
    } catch {
        Write-Host "Failed to retrieve Node.js version."
        return $null
    }
}

function Get-NodeProductCode {
    try {
        $productCode = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Node.js*" } | Select-Object -ExpandProperty IdentifyingNumber -First 1
        return $productCode
    } catch {
        Write-Host "Failed to retrieve Node.js product code."
        return $null
    }
}

function Uninstall-Node {
    $productCode = Get-NodeProductCode
    if ($productCode) {
        Write-Host "Uninstalling Node.js..."
        Start-Process msiexec.exe -ArgumentList "/x $productCode /qn" -Wait
        Write-Host "Node.js has been uninstalled."
    } else {
        Write-Host "No Node.js product code found, cannot uninstall."
    }
}

$installedVersion = Get-NodeVersion
if ($installedVersion) {
    if ($installedVersion -ne $TargetVersion) {
        Write-Host "Installed Node.js version is $installedVersion, which is not $TargetVersion."
        Uninstall-Node
    } else {
        Write-Host "Node.js version $TargetVersion is already installed."
    }
} else {
    Write-Host "Node.js is not installed."
}
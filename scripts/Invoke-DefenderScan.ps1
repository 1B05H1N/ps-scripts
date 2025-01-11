<#
.SYNOPSIS
    Runs a quick Windows Defender scan.

.DESCRIPTION
    Uses built-in Windows Defender cmdlets to initiate a quick scan
    for malware, then displays any detected threats.

.EXAMPLE
    .\Invoke-DefenderScan.ps1
    Performs a quick Defender scan on the local system.
#>

[CmdletBinding()]
param()

try {
    # Start-Transcript -Path "C:\Logs\Invoke-DefenderScan_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue
    
    # Ensure Defender cmdlets are available
    if (-not (Get-Command Start-MpScan -ErrorAction SilentlyContinue)) {
        Write-Error "Windows Defender PowerShell module not found. This script requires Windows Defender."
        return
    }
    
    Write-Host "Starting a quick Defender scan..."
    Start-MpScan -ScanType QuickScan
    
    # Optional: Wait/poll scanning progress
    Start-Sleep -Seconds 5
    
    # Fetch any recent detections
    $scanResults = Get-MpThreatDetection
    if ($scanResults) {
        Write-Host "Threats found:"
        $scanResults | Format-Table -AutoSize
    } else {
        Write-Host "No threats detected during the quick scan."
    }

} catch {
    Write-Error "An error occurred while running a Defender scan: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
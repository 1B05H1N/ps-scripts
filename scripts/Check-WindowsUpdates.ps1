<#
.SYNOPSIS
    Checks for available Windows updates.

.DESCRIPTION
    Uses the PSWindowsUpdate module (if installed) to query the system for pending updates.

.EXAMPLE
    .\Check-WindowsUpdates.ps1
#>

[CmdletBinding()]
param()

try {
    # Start-Transcript -Path "C:\Logs\Check-WindowsUpdates_$(Get-Date -Format 'yyyyMMdd').log" -ErrorAction SilentlyContinue

    # Ensure PSWindowsUpdate is installed
    # Install-Module PSWindowsUpdate -Force

    Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue
    $updates = Get-WindowsUpdate -Verbose:$false -IgnoreReboot

    if ($updates) {
        Write-Host "Available updates:"
        $updates | Select Title, KB, Size, UpdateID, IsDownloaded, IsInstalled
    } else {
        Write-Host "No updates found."
    }

} catch {
    Write-Error "An error occurred while checking for Windows updates: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
<#
.SYNOPSIS
    Archives the Security event log and then clears it.

.DESCRIPTION
    Uses the `wevtutil` command to export the Security event log to an EVTX file
    for archival, then clears the log to prevent overflow.

.PARAMETER ArchivePath
    The file path (.evtx) to store the archived log.

.EXAMPLE
    .\Archive-SecurityLog.ps1 -ArchivePath "C:\Logs\SecurityBackup.evtx"
    Exports the Security log to SecurityBackup.evtx and then clears it.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ArchivePath = "C:\Logs\SecurityBackup.evtx"
)

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "This script requires administrative privileges. Please run as Administrator."
}

try {
    # Start-Transcript -Path "C:\Logs\Archive-SecurityLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    if (-not (Test-Path (Split-Path $ArchivePath))) {
        # Ensure the directory exists
        $null = New-Item -ItemType Directory -Path (Split-Path $ArchivePath) -Force
    }

    Write-Host "Archiving Security event log to: $ArchivePath"
    wevtutil epl Security "$ArchivePath"

    Write-Host "Clearing Security event log..."
    wevtutil cl Security

    Write-Host "Security event log archived and cleared successfully."

} catch {
    Write-Error "An error occurred while archiving the Security log: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
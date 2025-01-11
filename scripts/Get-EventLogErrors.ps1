<#
.SYNOPSIS
    Retrieves errors and warnings from a specific Windows event log.

.DESCRIPTION
    Filters a selected event log for error or warning entries within the specified hours.

.PARAMETER LogName
    The event log name (e.g., System, Application).

.PARAMETER Hours
    The number of hours back to search. Defaults to 24.

.EXAMPLE
    .\Get-EventLogErrors.ps1 -LogName "System" -Hours 12
#>

[CmdletBinding()]
param(
    [string]$LogName = "System",
    [int]$Hours = 24
)

try {
    # Start-Transcript -Path "C:\Logs\Get-EventLogErrors_$(Get-Date -Format 'yyyyMMdd').log" -ErrorAction SilentlyContinue

    $timeThreshold = (Get-Date).AddHours(-$Hours)

    Get-EventLog -LogName $LogName -After $timeThreshold -EntryType Error, Warning |
        Select-Object EventID, Source, EntryType, TimeGenerated, Message |
        Sort-Object TimeGenerated -Descending

} catch {
    Write-Error "An error occurred while retrieving event log entries: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
<#
.SYNOPSIS
    Searches Security event logs for specific event IDs related to authentication or policy changes.

.DESCRIPTION
    Looks for noteworthy security events (e.g., logon failures, account lockouts, privilege use, etc.)
    within a user-defined timeframe. Useful for security monitoring or incident response.

.PARAMETER Hours
    Number of hours back to search in the Security event log.

.PARAMETER EventIDs
    A list of event IDs to filter on.

.EXAMPLE
    .\Check-SecurityEventLogs.ps1 -Hours 24 -EventIDs 4625,4740
    Displays authentication failures (4625) and account lockouts (4740) from the last 24 hours.
#>

[CmdletBinding()]
param(
    [int]$Hours = 24,
    [int[]]$EventIDs = @(4624, 4625, 4634)  # default IDs: Logon success, failure, and logoff
)

try {
    # Start-Transcript -Path "C:\Logs\Check-SecurityEventLogs_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    $timeLimit = (Get-Date).AddHours(-$Hours)
    Write-Host "Searching Security log for events since $($timeLimit.ToString())..."

    # Get events from the Security log with matching IDs
    $events = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID      = $EventIDs
        StartTime = $timeLimit
    } -ErrorAction SilentlyContinue

    if (-not $events) {
        Write-Host "No matching security events found."
        return
    }

    # Display key info
    $events | Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, @{Name="Message";Expression={$_.Message.Substring(0,200) + "..."}} |
        Sort-Object TimeCreated -Descending |
        Format-Table -AutoSize

} catch {
    Write-Error "An error occurred while checking Security event logs: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
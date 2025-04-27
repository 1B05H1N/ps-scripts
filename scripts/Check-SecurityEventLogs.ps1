<#
.SYNOPSIS
    Searches Security event logs for specific event IDs related to authentication or policy changes.

.DESCRIPTION
    This script provides comprehensive security event log analysis with advanced filtering
    and export capabilities. It searches for noteworthy security events such as logon
    failures, account lockouts, and privilege use within a user-defined timeframe.

    Features:
    - Search Security event logs with customizable time range
    - Filter by specific event IDs
    - Filter by username
    - Filter by severity level
    - Export results in multiple formats (CSV, XML, JSON)
    - Comprehensive error handling
    - Detailed event information display

    Common Event IDs:
    - 4624: Successful logon
    - 4625: Failed logon
    - 4634: Logoff
    - 4740: Account lockout
    - 4728: Member added to security group
    - 4732: Member removed from security group

.PARAMETER Hours
    Number of hours back to search in the Security event log.

.PARAMETER EventIDs
    A list of event IDs to filter on.

.PARAMETER Username
    Filter events by a specific username.

.PARAMETER Severity
    Filter events by severity level.

.PARAMETER ExportPath
    Path to save exported event logs.

.PARAMETER ExportFormat
    Format to export event logs.

.EXAMPLE
    .\Check-SecurityEventLogs.ps1 -Hours 24 -EventIDs 4625,4740
    Displays authentication failures (4625) and account lockouts (4740) from the last 24 hours.

.EXAMPLE
    .\Check-SecurityEventLogs.ps1 -Hours 48 -Username "admin" -Severity Critical,Error -ExportFormat CSV
    Exports critical and error events for the admin user from the last 48 hours to CSV.

.NOTES
    Author: Your Name
    Version: 1.0
    Date: 2024-04-27
    Requirements: Windows PowerShell 5.1 or later, Administrative privileges
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateRange(1, 720)]
    [int]$Hours = 24,
    
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [int[]]$EventIDs = @(4624, 4625, 4634),  # default IDs: Logon success, failure, and logoff

    [Parameter(Mandatory=$false)]
    [string]$Username,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Critical", "Error", "Warning", "Information", "Verbose", "Debug")]
    [string[]]$Severity = @("Critical", "Error", "Warning"),

    [Parameter(Mandatory=$false)]
    [string]$ExportPath = "C:\Logs\SecurityEvents",

    [Parameter(Mandatory=$false)]
    [ValidateSet("CSV", "XML", "JSON")]
    [string]$ExportFormat = "CSV"
)

#Requires -RunAsAdministrator

# Ensure export directory exists
if (-not (Test-Path $ExportPath)) {
    New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null
}

try {
    $timeLimit = (Get-Date).AddHours(-$Hours)
    
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

    # Filter by username if specified
    if ($Username) {
        $events = $events | Where-Object { $_.Properties[5].Value -like "*$Username*" }
    }

    # Filter by severity
    $events = $events | Where-Object { $_.LevelDisplayName -in $Severity }

    # Display key info
    $events | Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, @{Name="Message";Expression={$_.Message.Substring(0,[Math]::Min(200,$_.Message.Length)) + "..."}} |
        Sort-Object TimeCreated -Descending |
        Format-Table -AutoSize

    # Export events if any were found
    if ($events) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $exportFile = Join-Path $ExportPath "SecurityEvents_$timestamp"
        
        switch ($ExportFormat) {
            "CSV" {
                $events | Export-Csv -Path "$exportFile.csv" -NoTypeInformation
            }
            "XML" {
                $events | Export-Clixml -Path "$exportFile.xml"
            }
            "JSON" {
                $events | ConvertTo-Json | Out-File "$exportFile.json"
            }
        }
        Write-Host "Events exported to $exportFile.$($ExportFormat.ToLower())"
    }

} catch {
    Write-Error "An error occurred while checking Security event logs: $_"
} finally {
    Stop-Transcript -ErrorAction SilentlyContinue
}
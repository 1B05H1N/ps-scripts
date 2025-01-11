<#
.SYNOPSIS
    Manages a Windows service locally or remotely.

.DESCRIPTION
    Lists, starts, stops, or restarts a specified Windows service.

.PARAMETER ComputerName
    The target computer's hostname or IP. Defaults to the local computer.

.PARAMETER ServiceName
    The short name of the Windows service to manage.

.PARAMETER Action
    The action to take on the specified service. Options: List, Start, Stop, Restart.

.EXAMPLE
    .\ManageService.ps1 -ServiceName "Spooler" -Action "Restart"
    Restarts the Print Spooler on the local machine.
#>

[CmdletBinding()]
param(
    [string]$ComputerName = $env:COMPUTERNAME,
    [string]$ServiceName,
    [ValidateSet("List","Start","Stop","Restart")]
    [string]$Action = "List"
)

try {
    # Start-Transcript -Path "C:\Logs\ManageService_$(Get-Date -Format 'yyyyMMdd').log" -ErrorAction SilentlyContinue

    if (-not $ServiceName -and $Action -ne "List") {
        Write-Error "ServiceName must be specified for Start, Stop, or Restart."
        return
    }

    switch ($Action) {
        "List" {
            Get-Service -ComputerName $ComputerName |
                Select-Object Name, DisplayName, Status
        }
        "Start" {
            Start-Service -Name $ServiceName -ComputerName $ComputerName
            Write-Host "Started $ServiceName on $ComputerName"
        }
        "Stop" {
            Stop-Service -Name $ServiceName -ComputerName $ComputerName
            Write-Host "Stopped $ServiceName on $ComputerName"
        }
        "Restart" {
            Restart-Service -Name $ServiceName -ComputerName $ComputerName
            Write-Host "Restarted $ServiceName on $ComputerName"
        }
    }
} catch {
    Write-Error "An error occurred managing service '$ServiceName' on '$ComputerName': $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
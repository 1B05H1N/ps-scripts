<#
.SYNOPSIS
    Retrieves local user accounts on a Windows system.

.DESCRIPTION
    Lists local user accounts along with their enabled status, last logon, and description.
    Requires PowerShell 5.1 or later (LocalAccounts module).

.EXAMPLE
    .\Get-LocalUserAccounts.ps1
#>

[CmdletBinding()]
param()

try {
    # Start-Transcript -Path "C:\Logs\Get-LocalUserAccounts_$(Get-Date -Format 'yyyyMMdd').log" -ErrorAction SilentlyContinue

    $localUsers = Get-LocalUser -ErrorAction Stop
    $localUsers | 
        Select-Object Name, Enabled, LastLogon, Description |
        Sort-Object Name

} catch {
    Write-Error "An error occurred while retrieving local user accounts: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
<#
.SYNOPSIS
    Generates a report of new, disabled, and (optionally) deleted accounts in Active Directory.

.DESCRIPTION
    This script searches Active Directory for user accounts that meet certain criteria:
    - Created within a specified timeframe.
    - Disabled accounts.
    - Deleted accounts (if AD Recycle Bin is enabled).

.PARAMETER DaysBack
    Number of days to look back when searching for new or deleted accounts.

.PARAMETER ExportCsvPath
    (Optional) Path to export report files (New, Disabled, Deleted) in CSV format.

.EXAMPLE
    .\AD_AccountReport.ps1 -DaysBack 7
    Retrieves new, disabled, and deleted accounts over the past 7 days and displays results.

.EXAMPLE
    .\AD_AccountReport.ps1 -DaysBack 7 -ExportCsvPath "C:\Reports\ADReport"
    Same as above, and also exports CSV files.
#>

[CmdletBinding()]
param(
    [int]$DaysBack = 7,
    [string]$ExportCsvPath
)

try {
    # Check if Active Directory module is available
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory -ErrorAction Stop
    }

    $newAccounts = Get-ADUser -Filter "WhenCreated -ge '$($startDate.ToString('yyyy-MM-dd'))'" -Properties DisplayName,EmailAddress,whenCreated -ErrorAction Stop

    # Get disabled accounts
    $disabledAccounts = Get-ADUser -Filter "Enabled -eq 'False'" -Properties DisplayName,EmailAddress,whenCreated -ErrorAction Stop
    # Start-Transcript -Path "C:\Logs\AD_AccountReport_$(Get-Date -Format 'yyyyMMdd').log" -ErrorAction SilentlyContinue

    $startDate = (Get-Date).AddDays(-$DaysBack)

    # Get newly created accounts
    $newAccounts = Get-ADUser -Filter {WhenCreated -ge $startDate} -Properties DisplayName,EmailAddress,whenCreated

    # Get disabled accounts
    $disabledAccounts = Get-ADUser -Filter 'Enabled -eq $False' -Properties DisplayName,EmailAddress,whenCreated

    # Get deleted accounts (only if AD Recycle Bin is enabled)
    $deletedAccounts = @()
    try {
        $deletedAccounts = Get-ADObject -Filter 'IsDeleted -eq $True -and WhenChanged -ge $startDate' `
            -IncludeDeletedObjects -Properties * 2>$null
    } catch {
        Write-Verbose "Error: AD Recycle Bin might not be enabled or you lack permission."
    }

    # Display counts
    Write-Host "New Accounts:       $($newAccounts.Count)"
    Write-Host "Disabled Accounts:  $($disabledAccounts.Count)"
    Write-Host "Deleted Accounts:   $($deletedAccounts.Count)"

    # Export if needed
    if ($ExportCsvPath) {
        $newAccounts | Export-Csv "$ExportCsvPath-NewAccounts.csv" -NoTypeInformation
        $disabledAccounts | Export-Csv "$ExportCsvPath-DisabledAccounts.csv" -NoTypeInformation
        $deletedAccounts | Export-Csv "$ExportCsvPath-DeletedAccounts.csv" -NoTypeInformation
        Write-Host "Reports exported to $ExportCsvPath with suffixes for each category."
    }

} catch {
    Write-Error "An error occurred while generating the AD Account Report: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
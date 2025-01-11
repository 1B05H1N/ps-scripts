<#
.SYNOPSIS
    Lists installed software from registry entries.

.DESCRIPTION
    Retrieves installed programs from both 64-bit and 32-bit registry paths. 
    Optionally exports results to CSV.

.PARAMETER ExportCsvPath
    (Optional) Path to export the installed software list in CSV format.

.EXAMPLE
    .\Get-InstalledSoftware.ps1
#>

[CmdletBinding()]
param(
    [string]$ExportCsvPath
)

try {
    # Start-Transcript -Path "C:\Logs\Get-InstalledSoftware_$(Get-Date -Format 'yyyyMMdd').log" -ErrorAction SilentlyContinue

    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $softwareList = foreach ($path in $paths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue | ForEach-Object {
            [PSCustomObject]@{
                Name            = $_.DisplayName
                Version         = $_.DisplayVersion
                Publisher       = $_.Publisher
                InstallDate     = $_.InstallDate
                UninstallString = $_.UninstallString
            }
        }
    } | Where-Object { $_.Name -ne $null } | Sort-Object Name

    if ($ExportCsvPath) {
        $softwareList | Export-Csv -Path $ExportCsvPath -NoTypeInformation
        Write-Host "Software list exported to $ExportCsvPath"
    } else {
        $softwareList
    }

} catch {
    Write-Error "An error occurred while retrieving installed software: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
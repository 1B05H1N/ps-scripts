<#
.SYNOPSIS
    Displays disk usage for local drives.

.DESCRIPTION
    Retrieves usage statistics (total size, free space, used space, and percent free) for each local disk.

.EXAMPLE
    .\Get-DiskUsage.ps1
#>

[CmdletBinding()]
param()

try {
    # Start-Transcript -Path "C:\Logs\Get-DiskUsage_$(Get-Date -Format 'yyyyMMdd').log" -ErrorAction SilentlyContinue

    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        [PSCustomObject]@{
            DeviceID    = $_.DeviceID
            SizeGB      = (“{0:N2}” -f ($_.Size / 1GB))
            FreeSpaceGB = (“{0:N2}” -f ($_.FreeSpace / 1GB))
            UsedSpaceGB = (“{0:N2}” -f (($_.Size - $_.FreeSpace) / 1GB))
            PercentFree = (“{0:N2}%” -f (($_.FreeSpace / $_.Size) * 100))
        }
    } | Format-Table -AutoSize

} catch {
    Write-Error "An error occurred while retrieving disk usage: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}

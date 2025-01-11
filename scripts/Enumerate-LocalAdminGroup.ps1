<#
.SYNOPSIS
    Enumerates members of the local Administrators group.

.DESCRIPTION
    Lists all user and group accounts in the local Administrators group.
    Can help identify unauthorized or unexpected administrator privileges on the machine.

.EXAMPLE
    .\Enumerate-LocalAdminGroup.ps1
#>

[CmdletBinding()]
param()

try {
    # Start-Transcript -Path "C:\Logs\Enumerate-LocalAdminGroup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    Write-Host "Enumerating local Administrators group membership..."

    # Retrieve the local Administrators group (SID S-1-5-32-544) and list its members
    $adminGroup = [ADSI]"WinNT://$env:COMPUTERNAME/Administrators,group"
    $members = @()

    foreach ($member in $adminGroup.psbase.Invoke("Members")) {
        $obj = [ADSI]$member
        $members += [PSCustomObject]@{
            Name = $obj.Name
            Path = $obj.Path
        }
    }

    if ($members.Count -eq 0) {
        Write-Host "No members found in the local Administrators group."
    } else {
        Write-Host "Local Administrators group members:"
        $members | Sort-Object Name | Format-Table
    }

} catch {
    Write-Error "An error occurred while enumerating local Administrators group: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
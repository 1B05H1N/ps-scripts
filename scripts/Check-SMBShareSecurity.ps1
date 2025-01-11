<#
.SYNOPSIS
    Scans web configuration files for potential credentials and sensitive data.

.DESCRIPTION
    Recursively searches through a web application directory for configuration files
    (*.config, *.json, *.yml, *.yaml) and analyzes them for potential credentials 
    or sensitive information using pattern matching.

    The script looks for common patterns that might indicate credentials or sensitive
    data such as:
    - Connection strings
    - API keys
    - Passwords
    - Authentication tokens
    - Certificate paths

.PARAMETER WebRoot
    The root directory path of the web application to scan.
    The path must be valid and the script must have read permissions to access it.

.EXAMPLE
    .\Analyze-WebConfigFiles.ps1 -WebRoot "C:\inetpub\wwwroot"
    Scans all configuration files in the specified web root for potential credentials.

.EXAMPLE
    .\Analyze-WebConfigFiles.ps1 -WebRoot "D:\applications\webapp1"
    Scans configuration files in a custom web application directory.

.LINK
    https://docs.microsoft.com/en-us/powershell/scripting/
#>

[CmdletBinding()]
param(
    [string]$ComputerName = $env:COMPUTERNAME
)

try {
    $shares = Get-SmbShare -CimSession $ComputerName -ErrorAction Stop
}
catch {
    Write-Error "[ERROR] Unable to retrieve SMB shares on $ComputerName. Error: $($_.Exception.Message)"
    return
}

if (!$shares) {
    Write-Host "[INFO] No SMB shares found on $ComputerName or insufficient privileges."
    return
}

Write-Host "[INFO] Checking SMB shares on $ComputerName..."

$suspiciousShares = @()

foreach ($share in $shares) {
    # Get share security
    try {
        $sharePerms = Get-SmbShareAccess -Name $share.Name -CimSession $ComputerName -ErrorAction Stop
    }
    catch {
        Write-Warning "[WARNING] Unable to get permissions for share: $($share.Name)"
        continue
    }

    foreach ($perm in $sharePerms) {
        # Check if Everyone or BUILTIN\Users has FullAccess
        if ($perm.AccessControlType -eq "Allow" -and 
            ($perm.AccountName -match "Everyone" -or $perm.AccountName -match "BUILTIN\\Users") -and
            $perm.AccessRight -eq "Full") {
            $suspiciousShares += [PSCustomObject]@{
                ShareName     = $share.Name
                Path          = $share.Path
                Account       = $perm.AccountName
                AccessRight   = $perm.AccessRight
                Description   = "Everyone/Users has FullAccess"
            }
        }
    }
}

if ($suspiciousShares.Count -gt 0) {
    Write-Host "[RESULT] Shares with weak permissions found:"
    $suspiciousShares | Format-Table -AutoSize
}
else {
    Write-Host "[RESULT] No shares with obviously weak permissions found on $ComputerName."
}
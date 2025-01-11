<#
.SYNOPSIS
    Checks local password policy settings.

.DESCRIPTION
    Retrieves settings like minimum password length, maximum password age, and complexity requirements.

.EXAMPLE
    .\Check-PasswordPolicy.ps1
#>

[CmdletBinding()]
param()

try {
    # Start-Transcript -Path "C:\Logs\Check-PasswordPolicy_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    Write-Host "Checking local password policy..." -ForegroundColor Cyan

    # Export security policy to a temporary file
    $secFile = [System.IO.Path]::GetTempFileName()
    secedit /export /cfg $secFile /quiet

    # Read the security policy file
    $secPolicy = Get-Content $secFile
    
    # Parse the security settings
    $passwordPolicy = @{}
    $secPolicy | Where-Object { $_ -match '^[^;].*=.*' } | ForEach-Object {
        $key, $value = $_ -split '='
        $passwordPolicy[$key.Trim()] = $value.Trim()
    }

    Write-Host "`nPassword Policy Settings:" -ForegroundColor Green
    Write-Host "Minimum Password Length: $($passwordPolicy['MinimumPasswordLength'])"
    Write-Host "Maximum Password Age (days): $($passwordPolicy['MaximumPasswordAge'])"
    Write-Host "Minimum Password Age (days): $($passwordPolicy['MinimumPasswordAge'])"
    Write-Host "Password History Length: $($passwordPolicy['PasswordHistorySize'])"
    Write-Host "Password Complexity: $($passwordPolicy['PasswordComplexity'])"

    # Cleanup temp file
    Remove-Item $secFile -Force

} catch {
    Write-Error "An error occurred while checking password policy: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
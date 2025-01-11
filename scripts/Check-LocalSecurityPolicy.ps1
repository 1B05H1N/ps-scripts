<#
.SYNOPSIS
    Retrieves local security policy settings from the registry.

.DESCRIPTION
    Gathers common local security policy settings (e.g., Audit policy, User Rights assignments)
    by reading relevant registry keys. Useful for security audits or baselines.

.EXAMPLE
    .\Check-LocalSecurityPolicy.ps1
#>

[CmdletBinding()]
param()

# Check for administrator privileges
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    # Common registry paths for local security policies
    $auditPolicyPath = "HKLM:\System\CurrentControlSet\Control\Lsa"
    
    # Verify registry path exists
    if (-not (Test-Path $auditPolicyPath)) {
        throw "Could not access required registry path: $auditPolicyPath"
    }
    throw "This script requires administrator privileges. Please run as administrator."
}

try {
    # Start-Transcript -Path "C:\Logs\Check-LocalSecurityPolicy_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    Write-Host "Gathering local security policy settings..."

    # Common registry paths for local security policies
    $auditPolicyPath = "HKLM:\System\CurrentControlSet\Control\Lsa"
    $userRightsPath  = "HKLM:\Security\Policy\Secrets"  # Placeholder, or can expand to more specific subkeys

    # Check LSA protection (as an example)
    $lsaVal = Get-ItemProperty -Path $auditPolicyPath -Name "RunAsPPL" -ErrorAction SilentlyContinue
    if ($lsaVal -and $lsaVal.RunAsPPL -eq 1) {
        Write-Host "LSA Protection is ENABLED (RunAsPPL=1)."
    } else {
        Write-Host "LSA Protection is DISABLED or not configured."
    }

    # You can add more checks for different keys:
    # e.g., Check if NTLM is disabled, Audit policies, etc.

} catch {
    Write-Error "An error occurred while checking local security policy: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
<#
.SYNOPSIS
    Analyzes Windows registry settings for potentially weak or insecure configurations.

.DESCRIPTION
    This script examines specific Windows registry keys and values that are important
    for system security, comparing them against expected secure values. It checks for:
    - NTLM security settings
    - RDP encryption levels
    - Other security-related registry configurations

    The script provides detailed output about non-compliant settings found.

.EXAMPLE
    .\Check-WeakRegistrySettings.ps1
    Analyzes registry settings and displays those that don't match security expectations.

.NOTES
    Requires:
    - Windows operating system
    - Administrative privileges recommended

.OUTPUTS
    Displays a formatted table of non-compliant registry settings including the key path,
    value name, current value, and expected secure value.
#>

[CmdletBinding()]
param()

# Example keys: (Use official CIS baselines or MS documentation for real recommended values)
$registryChecks = @(
    @{
        Key  = "HKLM:\SYSTEM\CurrentControlSet\Control\LSA"
        Name = "LmCompatibilityLevel"
        ExpectedValue = 5  # Typically means NTLMv2 only
    },
    @{
        Key  = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
        Name = "MinEncryptionLevel"
        ExpectedValue = 3  # FIPS
    },
    @{
        Key  = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
        Name = "NtlmMinClientSec"
        ExpectedValue = 537395200 # Example for requiring NTLMv2 session security
    }
)

Write-Host "[INFO] Checking registry settings..."

$result = @()

foreach ($check in $registryChecks) {
    $key = $check.Key
    $name = $check.Name
    $expectedValue = $check.ExpectedValue

    try {
        $currentValue = Get-ItemProperty -Path $key -Name $name -ErrorAction Stop | Select-Object -ExpandProperty $name
        if ($currentValue -ne $expectedValue) {
            $result += [PSCustomObject]@{
                Key           = $key
                ValueName     = $name
                CurrentValue  = $currentValue
                ExpectedValue = $expectedValue
                IsCompliant   = $false
            }
        }
        else {
            $result += [PSCustomObject]@{
                Key           = $key
                ValueName     = $name
                CurrentValue  = $currentValue
                ExpectedValue = $expectedValue
                IsCompliant   = $true
            }
        }
    }
    catch {
        Write-Warning "[WARNING] Unable to read registry: $key\$name. Error: $($_.Exception.Message)"
    }
}

if ($result.Count -eq 0) {
    Write-Host "[RESULT] No registry items checked or no discrepancies found."
}
else {
    $nonCompliant = $result | Where-Object { $_.IsCompliant -eq $false }
    if ($nonCompliant) {
        Write-Host "[RESULT] Non-compliant registry settings detected:"
        $nonCompliant | Format-Table -AutoSize
    }
    else {
        Write-Host "[RESULT] All checked registry settings appear compliant."
    }
}
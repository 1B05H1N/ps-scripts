<#
.SYNOPSIS
    Detects potential phishing domains by analyzing domain names for suspicious patterns.

.DESCRIPTION
    This script analyzes domain names for common indicators of phishing attempts including:
    - Suspicious or free TLDs (.tk, .cn, .ru, etc.)
    - Typosquatting using leet speak (e.g. g00gle, micros0ft)
    - Unusually long domain names
    
    The script accepts domains via file input or direct parameter and provides detailed 
    output about any suspicious domains found.

.PARAMETER DomainList
    List of domains to analyze. Can be:
    - Path to a text file containing domains (one per line)
    - Array of domain strings
    - Single domain string

.EXAMPLE
    .\Detect-PhishingDomains.ps1 -DomainList domains.txt
    Analyzes domains from the specified text file.

.EXAMPLE
    .\Detect-PhishingDomains.ps1 -DomainList @("google.com", "g00gle.tk")
    Analyzes the provided array of domains.

.EXAMPLE
    .\Detect-PhishingDomains.ps1 -DomainList "suspicious-domain.tk"
    Analyzes a single domain.

.NOTES
    This is a basic implementation that could be enhanced with:
    - More sophisticated pattern matching
    - Integration with threat intelligence feeds
    - Domain reputation checking
    - Fuzzy matching algorithms
    - Additional phishing indicators

.OUTPUTS
    Displays a formatted table of analyzed domains showing:
    - Domain name
    - Whether it was flagged as suspicious
    - Reason for flagging (if applicable)
#>


[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    $DomainList
)

# Resolve if user provided a file path
if ((Test-Path $DomainList) -and (Get-Item $DomainList).PSIsContainer -eq $false) {
    # $DomainList is a file
    try {
        $domains = Get-Content -Path $DomainList -ErrorAction Stop | Where-Object { $_.Trim() -ne "" }
    }
    catch {
        Write-Error "[ERROR] Unable to read domain file: $($DomainList). Error: $($_.Exception.Message)"
        return
    }
}
elseif ($DomainList -is [System.Array]) {
    # $DomainList is an array of domains
    $domains = $DomainList
}
elseif ([string]::IsNullOrWhiteSpace($DomainList) -eq $false) {
    # Single domain string
    $domains = ,$DomainList
}
else {
    Write-Error "[ERROR] No valid domains provided."
    return
}

Write-Host "[INFO] Analyzing $(($domains).Count) domain(s) for suspicious patterns..."

$result = @()

foreach ($domain in $domains) {
    # Basic checks: numeric TLD, known suspicious TLD, leet-speak or random combos
    # This is simplistic; consider a more robust fuzzy matching library or 3rd-party service.

    $flags = @()

    # Check suspicious TLD
    if ($domain -match "\.(tk|cn|ru|top|gq|ml|cf|ga)$") {
        $flags += "Suspicious or free TLD"
    }

    # Check for leet speak or zeros in brand name
    if ($domain -match "g00gle|faceb00k|micros0ft") {
        $flags += "Possible typosquatting on brand"
    }

    # Check length
    if ($domain.Length -gt 50) {
        $flags += "Domain unusually long"
    }

    if ($flags.Count -gt 0) {
        $result += [PSCustomObject]@{
            Domain          = $domain
            IsSuspicious    = $true
            Reason          = $flags -join "; "
        }
    }
    else {
        $result += [PSCustomObject]@{
            Domain          = $domain
            IsSuspicious    = $false
            Reason          = "No known red flags"
        }
    }
}

if ($result.Count -gt 0) {
    $suspicious = $result | Where-Object { $_.IsSuspicious -eq $true }
    if ($suspicious) {
        Write-Host "[RESULT] Suspicious domains found:"
        $suspicious | Format-Table -AutoSize
    }
    else {
        Write-Host "[RESULT] No suspicious domains detected."
    }
}
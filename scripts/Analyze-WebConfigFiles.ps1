<#
.SYNOPSIS
    Scans web configuration files for potential credentials and sensitive data.

.DESCRIPTION
    Recursively searches through a web application directory for configuration files
    (*.config, *.json, *.yml, *.yaml) and analyzes them for potential credentials
    or sensitive information using pattern matching.

.PARAMETER WebRoot
    The root directory path of the web application to scan.

.EXAMPLE
    .\Analyze-WebConfigFiles.ps1 -WebRoot "C:\inetpub\wwwroot"
    Scans all configuration files in the specified web root for potential credentials.

.NOTES
    This script performs basic pattern matching and may produce false positives.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$WebRoot
)

if (-not (Test-Path $WebRoot)) {
    Write-Error "[ERROR] $WebRoot does not exist or is not accessible."
    return
}

Write-Host "[INFO] Scanning $WebRoot for config files..."
$configFiles = Get-ChildItem -Path $WebRoot -Include *.config,*.json,*.yml,*.yaml -Recurse -ErrorAction SilentlyContinue

if (!$configFiles) {
    Write-Host "[INFO] No config files found in $WebRoot."
    return
}

Write-Host "[INFO] Analyzing possible configuration files for credentials..."

$result = @()

foreach ($file in $configFiles) {
    try {
        $content = Get-Content -Path $file.FullName -ErrorAction Stop
    }
    catch {
        Write-Warning "[WARNING] Couldn't read file: $($file.FullName). Error: $($_.Exception.Message)"
        continue
    }

    $findings = @()
    # Simple regex patterns for potential credentials
    if ($content -match "(?i)(password\s*=\s*\"?.+\"?)") {
        $findings += "Password pattern found"
    }
    if ($content -match "(?i)(username\s*=\s*\"?.+\"?)") {
        $findings += "Username pattern found"
    }
    if ($content -match "(?i)(secret\s*:\s*\"?.+\"?)") {
        $findings += "Secret key pattern found"
    }
    if ($content -match "(?i)(api_key|client_secret|token)\s*[:=]\s*\"?.+\"?") {
        $findings += "API key or token pattern found"
    }

    if ($findings.Count -gt 0) {
        $result += [PSCustomObject]@{
            FilePath  = $file.FullName
            Suspicion = ($findings -join "; ")
        }
    }
}

if ($result) {
    Write-Host "[RESULT] Potentially sensitive data found:"
    $result | Format-Table -AutoSize
}
else {
    Write-Host "[RESULT] No obvious credentials found in scanned files."
}
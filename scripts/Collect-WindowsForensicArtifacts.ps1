<#
.SYNOPSIS
    Collects common Windows forensic artifacts for analysis.

.DESCRIPTION
    This script gathers key Windows forensic artifacts including:
    - Prefetch files
    - Registry hives (System, SAM, Security, Software, etc.)
    - Event logs (Application, System, Security, Setup)
    - Sysmon logs (if available)
    
    All artifacts are collected into a timestamped directory and optionally compressed.

.PARAMETER OutputPath
    Mandatory. Specifies the directory where collected artifacts will be stored.
    
.EXAMPLE
    .\Collect-WindowsForensicArtifacts.ps1 -OutputPath "C:\Investigation"
    Collects forensic artifacts and stores them in the specified directory.

.NOTES
    Requires:
    - Administrative privileges
    - PowerShell 5+ (for Compress-Archive functionality)
    - Sufficient disk space at output location

.OUTPUTS
    Creates a directory containing collected artifacts and optionally creates
    a compressed ZIP file of all collected items.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$OutputPath
)

# Ensure 7-Zip or Compress-Archive is available (PowerShell 5+)
if (-not (Get-Command Compress-Archive -ErrorAction SilentlyContinue)) {
    Write-Warning "[WARNING] Compress-Archive cmdlet not found. Please ensure you have PowerShell 5+ or 7-Zip installed."
}

# Validate OutputPath
if (-not (Test-Path $OutputPath)) {
    try {
        New-Item -ItemType Directory -Path $OutputPath -ErrorAction Stop | Out-Null
        Write-Host "[INFO] Created directory: $OutputPath"
    }
    catch {
        Write-Error "[ERROR] Cannot create or access directory: $OutputPath"
        return
    }
}

# Prepare artifact collection directory
$timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$artifactDir = Join-Path $OutputPath "Artifacts_$timestamp"

try {
    New-Item -ItemType Directory -Path $artifactDir -ErrorAction Stop | Out-Null
    Write-Host "[INFO] Created artifact collection directory: $artifactDir"
}
catch {
    Write-Error "[ERROR] Failed to create artifact directory: $($_.Exception.Message)"
    return
}

# 1. Collect Prefetch
Write-Host "[INFO] Collecting Prefetch files..."
$prefetchSource = "C:\Windows\Prefetch"
if (Test-Path $prefetchSource) {
    Copy-Item -Path $prefetchSource\* -Destination (Join-Path $artifactDir "Prefetch") -Recurse -ErrorAction SilentlyContinue
}

# 2. Collect Registry Hives (System, SAM, Security, Software, etc.)
Write-Host "[INFO] Collecting Registry hives..."
$regDir = Join-Path $artifactDir "Registry"
New-Item -ItemType Directory -Path $regDir -ErrorAction SilentlyContinue | Out-Null

$hives = @("SYSTEM","SAM","SECURITY","SOFTWARE","DEFAULT")
foreach ($hive in $hives) {
    try {
        reg save "HKLM\$hive" (Join-Path $regDir "$hive.hiv") /y | Out-Null
    }
    catch {
        Write-Warning "[WARNING] Failed to save hive: $hive"
    }
}

# 3. Collect Event Logs
Write-Host "[INFO] Collecting Event Logs..."
$logsDir = Join-Path $artifactDir "EventLogs"
New-Item -ItemType Directory -Path $logsDir -ErrorAction SilentlyContinue | Out-Null

# Common logs to export
$commonLogs = @("Application","System","Security","Setup")
foreach ($log in $commonLogs) {
    $evtxFile = Join-Path $logsDir "$log.evtx"
    try {
        wevtutil epl $log $evtxFile
    }
    catch {
        Write-Warning "[WARNING] Failed to export $log log. Error: $($_.Exception.Message)"
    }
}

# 4. Check for Sysmon logs
Write-Host "[INFO] Collecting Sysmon logs (if available)..."
if (Get-WinEvent -ListLog Sysmon -ErrorAction SilentlyContinue) {
    $sysmonLog = Join-Path $logsDir "Sysmon.evtx"
    try {
        wevtutil epl "Microsoft-Windows-Sysmon/Operational" $sysmonLog
    }
    catch {
        Write-Warning "[WARNING] Failed to export Sysmon log."
    }
}

# 5. (Optional) Collect Browser History
#    This may require specialized tools or reading each browser's DB.
#    Placeholder to copy from known paths or run a specialized extraction script.

Write-Host "[INFO] Collection complete. Attempting to compress artifacts..."

# Compress artifacts to a ZIP file
$zipPath = Join-Path $OutputPath "WindowsArtifacts_$timestamp.zip"
try {
    Compress-Archive -Path $artifactDir\* -DestinationPath $zipPath -ErrorAction Stop
    Write-Host "[INFO] Artifacts compressed to: $zipPath"
}
catch {
    Write-Warning "[WARNING] Failed to compress artifacts with Compress-Archive. Error: $($_.Exception.Message)"
    Write-Host "[INFO] You can manually zip the folder: $artifactDir"
}

Write-Host "[INFO] Forensic artifact collection completed."
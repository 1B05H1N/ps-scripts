<#
.SYNOPSIS
    Downloads a file from a specified URL and verifies its integrity using a provided hash.

.DESCRIPTION
    Uses Invoke-WebRequest to download a file to a local path. Then compares the file's
    computed hash against a known/expected hash (e.g., SHA-256).

.PARAMETER Uri
    The URL of the file to download.

.PARAMETER Destination
    The local path to save the file.

.PARAMETER ExpectedHash
    The expected SHA-256 hash of the file (e.g., from vendor site).

.EXAMPLE
    .\Download-FileWithHashCheck.ps1 -Uri "https://example.com/file.exe" -Destination "C:\Temp\file.exe" -ExpectedHash "ABC123..."
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Uri,

    [Parameter(Mandatory=$true)]
    [string]$Destination,

    [Parameter(Mandatory=$false)]
    [string]$ExpectedHash
)

try {
    # Start-Transcript -Path "C:\Logs\Download-FileWithHashCheck_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    Write-Host "Downloading file from $Uri..."
    Invoke-WebRequest -Uri $Uri -OutFile $Destination

    Write-Host "File saved to $Destination."

    if ($ExpectedHash) {
        Write-Host "Computing file hash..."
        $fileHash = Get-FileHash -Path $Destination -Algorithm SHA256
        Write-Host "Calculated SHA-256: $($fileHash.Hash)"

        if ($fileHash.Hash -eq $ExpectedHash.ToUpper()) {
            Write-Host "Hash verification succeeded. (Matches expected hash)"
        } else {
            Write-Warning "Hash verification failed! Expected: $ExpectedHash, Got: $($fileHash.Hash)"
        }
    } else {
        Write-Host "No ExpectedHash provided. Skipping hash verification."
    }

} catch {
    Write-Error "An error occurred while downloading or verifying the file: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
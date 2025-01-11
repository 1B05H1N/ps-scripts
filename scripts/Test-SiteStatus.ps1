<#
.SYNOPSIS
    Checks the HTTP response status of a website.

.DESCRIPTION
    Sends a HEAD or GET request to a given URL to confirm the site is reachable
    and returns the status code (e.g., 200 OK, 404 Not Found, 500 Internal Server Error).

.PARAMETER Uri
    The URL of the website to check.

.PARAMETER UseHead
    Switch to use a HEAD request instead of GET (often faster if you only need status).

.EXAMPLE
    .\Test-SiteStatus.ps1 -Uri "https://www.example.com" -UseHead
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Uri,

    [switch]$UseHead
)

try {
    # Start-Transcript -Path "C:\Logs\Test-SiteStatus_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    $method = if ($UseHead) { "HEAD" } else { "GET" }
    Write-Host "Checking $Uri using $method request..."

    $response = Invoke-WebRequest -Uri $Uri -Method $method -UseBasicParsing -ErrorAction Stop

    if ($response.StatusCode) {
        Write-Host "Site responded with status code: $($response.StatusCode) ($($response.StatusDescription))"
    } else {
        Write-Host "No StatusCode found in response."
    }

} catch {
    Write-Warning "Site check failed or site is unreachable. Error details: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
<#
.SYNOPSIS
    Calls a JSON-based public API and parses the response.

.DESCRIPTION
    Demonstrates how to make a GET request to a JSON REST API.
    Parses the JSON response and outputs key data.

.PARAMETER Uri
    The base URL or endpoint of the API.

.EXAMPLE
    .\Invoke-ApiRequest.ps1 -Uri "https://api.github.com/repos/PowerShell/PowerShell"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Uri
)

try {
    # Start-Transcript -Path "C:\Logs\Invoke-ApiRequest_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    Write-Host "Sending API request to $Uri..."

    # GitHub API requires a user-agent header, for example
    $headers = @{
        "User-Agent" = "MyPowerShellScript"
    }

    $response = Invoke-RestMethod -Uri $Uri -Headers $headers -Method GET

    if ($response) {
        Write-Host "Response received. Here is some parsed data: `n"
        # Display all keys or just a subset
        # For GitHub example: name, full_name, stargazers_count, watchers_count, forks_count, open_issues_count
        if ($response.name) {
            Write-Host "Name: $($response.name)"
        }
        if ($response.full_name) {
            Write-Host "Full Name: $($response.full_name)"
        }
        if ($response.stargazers_count -ne $null) {
            Write-Host "Stars: $($response.stargazers_count)"
        }
        if ($response.forks_count -ne $null) {
            Write-Host "Forks: $($response.forks_count)"
        }
        if ($response.open_issues_count -ne $null) {
            Write-Host "Open Issues: $($response.open_issues_count)"
        }
    } else {
        Write-Host "No data returned from the API."
    }

} catch {
    Write-Error "An error occurred while calling the API endpoint: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
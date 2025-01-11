<#
.SYNOPSIS
    Fetches a webpage and parses basic HTML elements (title, links, etc.).

.DESCRIPTION
    Uses Invoke-WebRequest to download a webpage, then extracts:
    - Page Title
    - Meta Description (if present)
    - All Hyperlinks (anchor tags)

    You can expand this to parse additional elements, such as headings (h1, h2, etc.),
    images, or forms.

.PARAMETER Uri
    The URL of the site to be fetched.

.EXAMPLE
    .\Get-WebsiteContent.ps1 -Uri "https://www.example.com"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Uri
)

try {
    # Start-Transcript -Path "C:\Logs\Get-WebsiteContent_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    Write-Host "Fetching content from $Uri..."

    $webResponse = Invoke-WebRequest -Uri $Uri -UseBasicParsing

    # Title
    $pageTitle = $webResponse.ParsedHtml.getElementsByTagName("title") | Select-Object -First 1
    if ($pageTitle) {
        Write-Host "Page Title: $($pageTitle.innerText)"
    } else {
        Write-Host "No <title> tag found."
    }

    # Meta Description
    $metaDescription = $webResponse.ParsedHtml.getElementsByTagName("meta") |
        Where-Object { $_.name -eq "description" } | Select-Object -First 1
    if ($metaDescription) {
        Write-Host "Meta Description: $($metaDescription.content)"
    } else {
        Write-Host "No meta 'description' found."
    }

    # All Anchor Tags
    Write-Host "`nLinks found on the page:"
    $links = $webResponse.Links | Select-Object href, innerText
    if ($links) {
        $links | Format-Table -AutoSize
    } else {
        Write-Host "No links found."
    }

} catch {
    Write-Error "An error occurred while fetching or parsing $Uri: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
<#
.SYNOPSIS
    Fetches an RSS feed and parses the XML to display titles and links.

.DESCRIPTION
    Uses Invoke-RestMethod (or Invoke-WebRequest) to get RSS feed data in XML,
    then iterates through <item> elements to display each title and link.

.PARAMETER FeedUrl
    The URL of the RSS feed (e.g., a blog feed).

.EXAMPLE
    .\Get-RssFeed.ps1 -FeedUrl "https://feeds.feedburner.com/PowershellBlog"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$FeedUrl
)

try {
    # Start-Transcript -Path "C:\Logs\Get-RssFeed_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    Write-Host "Fetching RSS feed from $FeedUrl..."
    $feedData = Invoke-RestMethod -Uri $FeedUrl -Method GET -ErrorAction Stop

    # RSS typically has channel > item structure
    $items = $feedData.rss.channel.item
    if (-not $items) {
        Write-Host "No <item> elements found in feed."
        return
    }

    Write-Host "Feed Items:"
    foreach ($item in $items) {
        [PSCustomObject]@{
            Title = $item.title
            Link  = $item.link
            Date  = $item.pubDate
        }
    } | Format-Table -AutoSize

} catch {
    Write-Error "Error occurred while fetching or parsing RSS feed: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
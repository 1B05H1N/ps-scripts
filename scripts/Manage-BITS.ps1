<#
.SYNOPSIS
    Manages Background Intelligent Transfer Service (BITS) jobs (start, monitor, complete, remove).

.DESCRIPTION
    Creates a BITS job for downloading or uploading files,
    monitors active jobs, completes them, or removes them if no longer needed.

.PARAMETER Action
    The action to perform: Start, Monitor, Complete, or Remove.

.PARAMETER RemoteUri
    (For Start) The source file URL (or destination if uploading).

.PARAMETER LocalPath
    (For Start) The local file path (download destination or upload source).

.EXAMPLE
    .\Manage-BITS.ps1 -Action Start -RemoteUri "https://example.com/file.zip" -LocalPath "C:\Temp\file.zip"
    Creates a BITS job to download file.zip to C:\Temp.

.EXAMPLE
    .\Manage-BITS.ps1 -Action Monitor
    Lists all current BITS jobs.

.EXAMPLE
    .\Manage-BITS.ps1 -Action Complete
    Completes all active BITS jobs if they're in a transferable state.
#>

[CmdletBinding()]
param(
    [ValidateSet("Start","Monitor","Complete","Remove")]
    [string]$Action = "Start",
    [string]$RemoteUri,
    [string]$LocalPath
)

try {
    # Start-Transcript -Path "C:\Logs\Manage-BITS_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    switch ($Action) {
        "Start" {
            if (-not $RemoteUri -or -not $LocalPath) {
                Write-Error "You must specify -RemoteUri and -LocalPath to start a BITS job."
                return
            }
            $job = Start-BitsTransfer -Source $RemoteUri -Destination $LocalPath -Asynchronous
            Write-Host "BITS job started: $($job.DisplayName)."
        }
        "Monitor" {
            $jobs = Get-BitsTransfer
            if ($jobs) {
                $jobs | Select-Object DisplayName, JobState, BytesTransferred, BytesTotal
            } else {
                Write-Host "No active BITS jobs found."
            }
        }
        "Complete" {
            $allJobs = Get-BitsTransfer
            if ($allJobs) {
                foreach ($job in $allJobs) {
                    Complete-BitsTransfer -BitsJob $job
                    Write-Host "Completed BITS job '$($job.DisplayName)'."
                }
            } else {
                Write-Host "No active BITS jobs to complete."
            }
        }
        "Remove" {
            $allJobs = Get-BitsTransfer
            if ($allJobs) {
                foreach ($job in $allJobs) {
                    Remove-BitsTransfer -BitsJob $job
                    Write-Host "Removed BITS job '$($job.DisplayName)'."
                }
            } else {
                Write-Host "No active BITS jobs to remove."
            }
        }
    }
    
} catch {
    Write-Error "An error occurred in Manage-BITS: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
<#
.SYNOPSIS
    Manages Windows scheduled tasks (list, create, or remove).

.DESCRIPTION
    Creates a new scheduled task with a daily trigger, lists existing tasks,
    or removes a specified task by name.

.PARAMETER Action
    The action to perform: List, Create, or Remove.

.PARAMETER TaskName
    The name of the scheduled task (required for Create/Remove).

.PARAMETER ScriptPath
    Path to the script or program to schedule (required for Create).

.PARAMETER Schedule
    (Optional) Frequency of the task. Default is Daily; can be modified for Weekly, Monthly, etc.

.EXAMPLE
    .\Manage-ScheduledTask.ps1 -Action List
    Lists all scheduled tasks.

.EXAMPLE
    .\Manage-ScheduledTask.ps1 -Action Create -TaskName "DailyScriptTask" -ScriptPath "C:\Scripts\MyScript.ps1"
    Creates a daily scheduled task named "DailyScriptTask" that runs MyScript.ps1 at 9:00 AM.

.EXAMPLE
    .\Manage-ScheduledTask.ps1 -Action Remove -TaskName "DailyScriptTask"
    Removes the scheduled task named "DailyScriptTask".
#>

[CmdletBinding()]
param(
    [ValidateSet("List","Create","Remove")]
    [string]$Action = "List",

    [string]$TaskName,

    [string]$ScriptPath,

    [ValidateSet("Daily","Hourly","Weekly","Monthly")]
    [string]$Schedule = "Daily"
)

try {
    # Start-Transcript -Path "C:\Logs\Manage-ScheduledTask_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue
    
    switch ($Action) {
        "List" {
            Get-ScheduledTask |
                Select-Object TaskName, State, LastRunTime, NextRunTime |
                Sort-Object TaskName
        }
        "Create" {
            if (-not $TaskName -or -not $ScriptPath) {
                Write-Error "You must specify -TaskName and -ScriptPath when creating a scheduled task."
                return
            }

            # Example: fixed daily trigger at 9:00 AM 
            # Adjust times/triggers or add more advanced logic as needed
            $trigger = New-ScheduledTaskTrigger -At 9:00AM -Daily 

            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$ScriptPath`""

            Register-ScheduledTask -TaskName $TaskName -Trigger $trigger -Action $action -RunLevel Highest | Out-Null
            Write-Host "Scheduled task '$TaskName' created to run '$ScriptPath' daily at 9:00 AM."
        }
        "Remove" {
            if (-not $TaskName) {
                Write-Error "You must specify -TaskName to remove a scheduled task."
                return
            }
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host "Scheduled task '$TaskName' has been removed."
        }
    }

} catch {
    Write-Error "An error occurred while managing scheduled tasks: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
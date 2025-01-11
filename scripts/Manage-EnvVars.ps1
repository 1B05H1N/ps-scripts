<#
.SYNOPSIS
    Manages environment variables for the current user or system.

.DESCRIPTION
    Lists, adds, or removes environment variables based on parameters.

.PARAMETER Name
    The name of the environment variable to add/remove.

.PARAMETER Value
    The value to assign if adding a variable.

.PARAMETER Scope
    Where to set the variable: User or Machine.

.PARAMETER Action
    List, Add, or Remove.

.EXAMPLE
    .\Manage-EnvVars.ps1 -Action List -Scope Machine
#>

[CmdletBinding()]
param(
    [string]$Name,
    [string]$Value,
    [ValidateSet("User","Machine")]
    [string]$Scope = "User",
    [ValidateSet("List","Add","Remove")]
    [string]$Action = "List"
)

try {
    # Start-Transcript -Path "C:\Logs\Manage-EnvVars_$(Get-Date -Format 'yyyyMMdd').log" -ErrorAction SilentlyContinue

    switch ($Action) {
        "List" {
            [System.Environment]::GetEnvironmentVariables($Scope)
        }
        "Add" {
            if (-not $Name -or -not $Value) {
                Write-Error "You must specify both -Name and -Value to add an environment variable."
                return
            }
            [System.Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
            Write-Host "Set environment variable '$Name' to '$Value' (Scope: $Scope)."
        }
        "Remove" {
            if (-not $Name) {
                Write-Error "You must specify -Name to remove an environment variable."
                return
            }
            [System.Environment]::SetEnvironmentVariable($Name, $null, $Scope)
            Write-Host "Removed environment variable '$Name' (Scope: $Scope)."
        }
    }

} catch {
    Write-Error "An error occurred while managing environment variables: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
<#
.SYNOPSIS
    Manages Windows Firewall rules (list, add, or remove).

.DESCRIPTION
    Allows you to list existing Windows Firewall rules, create a new rule
    (for inbound or outbound traffic), or remove an existing rule by name.

.PARAMETER Action
    The firewall action: List, Add, or Remove.

.PARAMETER RuleName
    The display name of the firewall rule (required for Add/Remove).

.PARAMETER Direction
    Inbound or Outbound (applies only when creating a rule).

.PARAMETER Program
    (Optional) File path for the program this rule applies to.

.PARAMETER RemotePort
    (Optional) Port number for the firewall rule.
    Required if you're creating a rule for a specific port.

.EXAMPLE
    .\Manage-FirewallRules.ps1 -Action List
    Lists all firewall rules.

.EXAMPLE
    .\Manage-FirewallRules.ps1 -Action Add -RuleName "Allow MyApp" -Direction Inbound -Program "C:\MyApp\app.exe" -RemotePort 8080
    Adds an inbound rule named "Allow MyApp" allowing TCP traffic on port 8080 for the specified program.

.EXAMPLE
    .\Manage-FirewallRules.ps1 -Action Remove -RuleName "Allow MyApp"
    Removes the specified firewall rule.
#>

[CmdletBinding()]
param(
    [ValidateSet("List","Add","Remove")]
    [string]$Action = "List",

    [string]$RuleName,

    [ValidateSet("Inbound","Outbound")]
    [string]$Direction = "Inbound",

    [string]$Program,

    [int]$RemotePort
)

try {
    # Start-Transcript -Path "C:\Logs\Manage-FirewallRules_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -ErrorAction SilentlyContinue

    switch ($Action) {
        "List" {
            Get-NetFirewallRule |
                Select-Object DisplayName, Direction, Action, Enabled, Profile |
                Sort-Object DisplayName
        }
        "Add" {
            if (-not $RuleName) {
                Write-Error "You must specify -RuleName when adding a firewall rule."
                return
            }
            if (-not $RemotePort) {
                Write-Error "You must specify -RemotePort when adding a firewall rule (for port-based rules)."
                return
            }
            New-NetFirewallRule `
                -DisplayName $RuleName `
                -Direction $Direction `
                -Program $Program `
                -Protocol TCP `
                -LocalPort $RemotePort `
                -Action Allow |
                Out-Null
            Write-Host "Created firewall rule '$RuleName' ($Direction) on port $RemotePort."
        }
        "Remove" {
            if (-not $RuleName) {
                Write-Error "You must specify -RuleName to remove a firewall rule."
                return
            }
            Remove-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue
            Write-Host "Removed firewall rule '$RuleName'."
        }
    }

} catch {
    Write-Error "An error occurred in Manage-FirewallRules: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}
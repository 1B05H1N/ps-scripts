<#
.SYNOPSIS
    Manages Windows Firewall rules (list, add, or remove).

.DESCRIPTION
    This script provides comprehensive management of Windows Firewall rules with support for
    multiple protocols, profiles, and port configurations. It allows you to list existing rules,
    create new rules for inbound or outbound traffic, and remove existing rules by name.

    Features:
    - List all firewall rules with filtering by profile
    - Create new rules with support for TCP and UDP protocols
    - Configure rules for specific programs or port ranges
    - Apply rules to specific network profiles (Domain, Private, Public)
    - Comprehensive logging of all operations
    - Error handling and validation

    The script is particularly useful for:
    - Security auditing and compliance
    - Application deployment and configuration
    - Network security management
    - Troubleshooting network connectivity issues

.PARAMETER Action
    The firewall action: List, Add, or Remove.

.PARAMETER RuleName
    The display name of the firewall rule (required for Add/Remove).

.PARAMETER Direction
    Inbound or Outbound (applies only when creating a rule).

.PARAMETER Program
    (Optional) File path for the program this rule applies to.

.PARAMETER RemotePorts
    (Optional) Port numbers for the firewall rule.
    Required if you're creating a rule for multiple ports.

.PARAMETER Protocol
    (Optional) Protocol for the firewall rule.
    Default is TCP.

.PARAMETER Profiles
    (Optional) Network profiles for the firewall rule.
    Default is "Any".

.PARAMETER LogPath
    (Optional) Path to the log directory.
    Default is "C:\Logs\FirewallRules".

.EXAMPLE
    .\Manage-FirewallRules.ps1 -Action List
    Lists all firewall rules.

.EXAMPLE
    .\Manage-FirewallRules.ps1 -Action Add -RuleName "Allow MyApp" -Direction Inbound -Program "C:\MyApp\app.exe" -RemotePorts 8080,8081
    Adds an inbound rule named "Allow MyApp" allowing TCP traffic on ports 8080 and 8081 for the specified program.

.EXAMPLE
    .\Manage-FirewallRules.ps1 -Action Add -RuleName "Allow WebServer" -Direction Inbound -Protocol UDP -RemotePorts 53,123 -Profiles Domain,Private
    Adds a UDP rule for DNS and NTP traffic on domain and private networks.

.EXAMPLE
    .\Manage-FirewallRules.ps1 -Action Remove -RuleName "Allow MyApp"
    Removes the specified firewall rule.

.NOTES
    Author: Your Name
    Version: 1.0
    Date: 2024-04-27
    Requirements: Windows PowerShell 5.1 or later, Administrative privileges
#>

[CmdletBinding()]
param(
    [ValidateSet("List","Add","Remove")]
    [string]$Action = "List",

    [string]$RuleName,

    [ValidateSet("Inbound","Outbound")]
    [string]$Direction = "Inbound",

    [string]$Program,

    [string[]]$RemotePorts,

    [ValidateSet("TCP","UDP","Any")]
    [string]$Protocol = "TCP",

    [ValidateSet("Domain","Private","Public","Any")]
    [string[]]$Profiles = @("Any"),

    [string]$LogPath = "C:\Logs\FirewallRules"
)

# Ensure log directory exists
if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

$logFile = Join-Path $LogPath "Manage-FirewallRules_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Start-Transcript -Path $logFile -ErrorAction SilentlyContinue

try {
    switch ($Action) {
        "List" {
            $rules = Get-NetFirewallRule
            if ($Profiles -ne "Any") {
                $rules = $rules | Where-Object { $_.Profiles -in $Profiles }
            }
            $rules | Select-Object DisplayName, Direction, Action, Enabled, Profile, Protocol |
                Sort-Object DisplayName
        }
        "Add" {
            if (-not $RuleName) {
                Write-Error "You must specify -RuleName when adding a firewall rule."
                return
            }
            if (-not $RemotePorts) {
                Write-Error "You must specify -RemotePorts when adding a firewall rule (for port-based rules)."
                return
            }

            $params = @{
                DisplayName = $RuleName
                Direction = $Direction
                Action = "Allow"
            }

            if ($Program) {
                $params.Program = $Program
            }

            if ($Protocol -ne "Any") {
                $params.Protocol = $Protocol
                $params.LocalPort = $RemotePorts
            }

            if ($Profiles -ne "Any") {
                $params.Profile = $Profiles
            }

            New-NetFirewallRule @params | Out-Null
            Write-Host "Created firewall rule '$RuleName' ($Direction) on ports $($RemotePorts -join ',') with protocol $Protocol"
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
    Stop-Transcript -ErrorAction SilentlyContinue
}
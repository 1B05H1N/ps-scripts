# PowerShell System Administration Scripts

A collection of PowerShell scripts for system administration, security monitoring, and maintenance tasks.

## Script Categories

### Security & Monitoring
- `Manage-FirewallRules.ps1` - Manage Windows Firewall rules (list, add, remove) with support for multiple protocols and profiles
- `Check-SecurityEventLogs.ps1` - Search and analyze Security event logs with filtering and export capabilities
- `Monitor-SystemResources.ps1` - Real-time system resource monitoring with customizable thresholds and alerts
- `Check-SuspiciousProcesses.ps1` - Detect potentially malicious processes
- `Check-SuspiciousScheduledTasks.ps1` - Identify suspicious scheduled tasks
- `Check-LocalSecurityPolicy.ps1` - Audit local security policy settings
- `Check-PasswordPolicy.ps1` - Verify password policy compliance
- `Check-SMBShareSecurity.ps1` - Audit SMB share security settings
- `Detect-PhishingDomains.ps1` - Check domains against known phishing lists
- `Collect-WindowsForensicArtifacts.ps1` - Collect forensic artifacts for investigation

### System Management
- `ManageService.ps1` - Manage Windows services
- `Manage-ScheduledTask.ps1` - Create and manage scheduled tasks
- `Manage-BITS.ps1` - Manage Background Intelligent Transfer Service
- `Manage-EnvVars.ps1` - Manage environment variables
- `Get-SystemInfo.ps1` - Collect comprehensive system information
- `Get-InstalledSoftware.ps1` - List installed software
- `Get-LocalUserAccounts.ps1` - List and manage local user accounts
- `Get-NetworkConfig.ps1` - Display network configuration
- `Get-DiskUsage.ps1` - Analyze disk usage
- `Get-EventLogErrors.ps1` - Retrieve error events from logs

### Network & Connectivity
- `Test-SiteStatus.ps1` - Check website availability and response times
- `Get-WebsiteContent.ps1` - Retrieve and parse website content
- `Invoke-ApiRequest.ps1` - Make API requests with error handling
- `Get-RssFeed.ps1` - Parse and display RSS feeds
- `Test-NetworkConnectivity.ps1` - Comprehensive network connectivity testing

### Active Directory
- `AD_AccountReport.ps1` - Generate Active Directory account reports
- `Enumerate-LocalAdminGroup.ps1` - List local administrator group members

### Security Analysis
- `Check-WeakRegistrySettings.ps1` - Identify weak registry security settings
- `Analyze-WebConfigFiles.ps1` - Analyze web.config files for security issues
- `Archive-SecurityLog.ps1` - Archive and compress security logs

## Usage

Each script includes detailed documentation in its header section. To view the documentation for any script, use:

```powershell
Get-Help .\ScriptName.ps1 -Detailed
```

## Requirements

- Windows PowerShell 5.1 or PowerShell Core 7+
- Administrative privileges for most scripts
- Windows 10/11 or Windows Server 2016/2019/2022

## Installation

1. Clone this repository:
```powershell
git clone https://github.com/1B05H1N/ps-scripts.git
```

2. Navigate to the scripts directory:
```powershell
cd ps-scripts/scripts
```

3. Run any script with appropriate parameters:
```powershell
.\ScriptName.ps1 -Parameter Value
```

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

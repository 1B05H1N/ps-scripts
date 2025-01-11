<#
.SYNOPSIS
    Retrieves network adapter configuration details.

.DESCRIPTION
    Gathers IP addresses, default gateway, and DNS server info for active network adapters.

.PARAMETER ExportCsvPath
    (Optional) Path to export the adapter details in CSV format.

.EXAMPLE
    .\Get-NetworkConfig.ps1 -ExportCsvPath "C:\Reports\NetworkConfig.csv"
#>

[CmdletBinding()]
param(
    [string]$ExportCsvPath
)

try {
    # Start-Transcript -Path "C:\Logs\Get-NetworkConfig_$(Get-Date -Format 'yyyyMMdd').log" -ErrorAction SilentlyContinue

    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    $networkInfo = foreach ($adapter in $adapters) {
        $ipConfig = Get-NetIPConfiguration -InterfaceAlias $adapter.Name
        foreach ($ip in $ipConfig.IPAddress) {
            [PSCustomObject]@{
                AdapterName    = $adapter.Name
                InterfaceIndex = $adapter.InterfaceIndex
                IPAddress      = $ip.IPAddress
                DefaultGateway = ($ipConfig.IPv4DefaultGateway | Select-Object -ExpandProperty NextHop -ErrorAction SilentlyContinue)
                DNSServers     = $ipConfig.DnsServer.ServerAddresses -join ";"
            }
        }
    }

    if ($ExportCsvPath) {
        $networkInfo | Export-Csv -Path $ExportCsvPath -NoTypeInformation
        Write-Host "Network information exported to $ExportCsvPath"
    } else {
        $networkInfo
    }

} catch {
    Write-Error "An error occurred while retrieving network configuration: $_"
} finally {
    # Stop-Transcript -ErrorAction SilentlyContinue
}

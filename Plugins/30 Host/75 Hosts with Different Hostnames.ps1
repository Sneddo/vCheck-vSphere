# Start of Settings
# End of Settings

# Changelog
## 1.0 : Initial plugin release
## 1.1 : Added Provider code

# Requires the vSphere provider for information
Import-Provider vSphere
$VMH = Get-vCheckvSphereObject "Hosts"

$report = @($VMH | Where-Object {$_.Name.Split('.')[0] -ne $_.NetworkInfo.HostName} | Select-Object -Property Name,@{Name="HostName";Expression={$_.NetworkInfo.HostName}} | Sort-Object -Property Name)
$report

$Title = "Hosts with different hostname"
$Header = ("Hosts with different hostname: {0}" -f $Report.Count)
$Comments = "The following hosts have a different hostname than their name in the vCenter Server. This might give troubles with HA."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

Remove-Variable report
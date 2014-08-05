# Start of Settings 
# The Syslog server which should be set on your hosts
$SyslogServer = "syslogserver"
# End of Settings

# Changelog
## 1.1 : ???
## 1.2 : Added Provider code

# Requires the vSphere provider for information
Import-Provider vSphere
$VMH = Get-vCheckvSphereObject "Hosts"

@($VMH | Where-Object {$_.ExtensionData.Summary.Config.Product.Name -eq 'VMware ESXi'} | Select-Object Name,@{Name='SyslogServer';Expression = {($_ | Get-VMHostSysLogServer).Host}},@{Name='SyslogSetting';Expression = {($_ | Get-AdvancedSetting -Name Syslog.Local.DatastorePath).Value| Where-Object {$_ -ne $NULL}}} | Where-Object {$_.SyslogServer -ne $SyslogServer -and $_.SyslogSetting -ne $SyslogServer})

$Title = "Syslog Name"
$Header = "Syslog Issues"
$Comments = "The following hosts do not have the correct Syslog settings which may cause issues if ESXi hosts experience issues and logs need to be investigated"
$Display = "Table"
$Author = "Jonathan Medd"
$PluginVersion = 1.1
$PluginCategory = "vSphere"
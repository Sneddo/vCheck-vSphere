# Start of Settings 
# End of Settings 

# Changelog
## 1.1 : ???
## 1.2 : Added Provider code

# Requires the vSphere provider for information
Import-Provider vSphere

$RespondHosts = @((Get-vCheckvSphereObject "Hosts") | where {$_.Runtime.ConnectionState -notmatch "Connected|Maintenance"} | Select name, @{N="Connection State";E={$_.ExtensionData.Runtime.ConnectionState}}, @{N="Power State";E={$_.ExtensionData.Runtime.PowerState}})
$RespondHosts

$Title = "Hosts Not responding or Disconnected"
$Header = ("Hosts not responding or disconnected : {0}" -f @($RespondHosts).count)
$Comments = "Hosts which are in a disconnected state will not be running any virtual machine workloads, check the below Hosts are in an expected state"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

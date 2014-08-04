# Start of Settings 
# End of Settings 

# Requires vSphere Provider
Import-Provider vSphere

(Get-vCheckvSphereObject "Hosts") | where {$_.ConnectionState -match "Maintenance"} | Select Name, ConnectionState

$Title = "Hosts in Maintenance Mode"
$Header = "Hosts in Maintenance Mode : $(@($MaintHosts).count)"
$Comments = "Hosts held in Maintenance mode will not be running any virtual machine workloads, check the below Hosts are in an expected state"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

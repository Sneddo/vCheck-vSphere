# Start of Settings 
# vSwitch Port Left
$vSwitchLeft =5
# End of Settings

# Requires vSphere Provider
Import-Provider vSphere

(Get-vCheckvSphereObject "vSwitches") | Where {$_.NumPortsAvailable -lt $($vSwitchLeft)} | Sort-Object NumPortsAvailable | Select VMHost, Name, NumPortsAvailable


$Title = "Checking Standard vSwitch Ports Free"
$Header = "Standard vSwitch with less than $vSwitchLeft Port(s) Free: {count}"
$Comments = "The following standard vSwitches have less than $vSwitchLeft left"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

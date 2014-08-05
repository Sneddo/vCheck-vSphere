# Start of Settings 
# End of Settings 

# Changelog
## 1.1 : ???
## 1.2 : Added Provider code

# Requires the vSphere provider for information
Import-Provider vSphere

Get-vCheckvSphereObject "HostsViews"| Select @{Name="OS"; Expression={$_.Summary.Config.product.fullName}} | Group-object OS | Select @{Name="OS"; Expression={$_.Name}},Count | Sort-Object Count -desc

$Title = "Host Build versions in use"
$Header = "Host Build versions in use"
$Comments = "The following host builds are in use in this vCenter"
$Display = "Table"
$Author = "Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

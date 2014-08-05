# Start of Settings 
# End of Settings 

# Changelog
## 1.1 : ???
## 1.2 : Provider code added

# Requires the vSphere provider for information
Import-Provider vSphere
$VMH = Get-vCheckvSphereObject "Hosts"

$ESXiLockDown = $VMH | Where {$_.ConnectionState -match "Connected|Maintenance" -and $_.ExtensionData.Summary.Config.Product.Name -match "i" -and $_.LockedMode -eq $false} | Select Name, @{N="LockedMode";E={$_.ExtensionData.Config.AdminDisabled}} 

$Title = "ESXi hosts which do not have Lockdown mode enabled"
$Header = ("ESXi Hosts with Lockdown Mode not Enabled : {0}" -f @($ESXiLockDown).count)
$Comments = "The following ESXi Hosts do not have lockdown enabled, think about using lockdown as an extra security feature."
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

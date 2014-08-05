# Start of Settings
# Include Hosts in Maintenance mode
$IncludeMaintenance = $false
# End of Settings

# Changelog
## 1.1 : ???
## 1.2 : ???
## 1.3 : Added Provider code

# Requires the vSphere provider for information
Import-Provider vSphere

$AlarmActionsEnabled =	Get-vCheckvSphereObject "Hosts" | Where { (-not $_.ExtensionData.AlarmActionsEnabled)} | 
									Select @{Name="Host"; Expression={$_.Name}}, @{"Name"="InMaintenanceMode";Expression={$_.ExtensionData.Runtime.InMaintenanceMode}}, @{"Name"="AlarmActionsEnabled"; Expression={$_.ExtensionData.AlarmActionsEnabled}} |
									Sort-Object Host

if ($IncludeMaintenance -eq $false) {
	$AlarmActionsEnabled = $AlarmActionsEnabled | Where {-not $_.InMaintenanceMode}
}
$AlarmActionsEnabled

$Title = "Hosts with Alarm disabled"
$Header = ("Hosts with Alarms disabled : {0}" -f @($AlarmActionsEnabled).Count)
$Comments = "The following Hosts have Alarm disabled. This may impact the Alarming of your infrastructure."
$Display = "Table"
$Author = "Denis Gauthier"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

Remove-Variable AlarmActionsEnabled
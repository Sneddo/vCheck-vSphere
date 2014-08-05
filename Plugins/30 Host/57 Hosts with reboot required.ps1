# Start of Settings
# End of Settings

# Changelog
## 1.1 : ???
## 1.2 : Added Provider code

# Requires the vSphere provider for information
Import-Provider vSphere
$VMH = Get-vCheckvSphereObject "Hosts"

$Result = @($VMH | Where-Object {$_.ExtensionData.Summary.RebootRequired} | Select-Object -Property Name, State)
$Result

$Title = "Hosts with reboot required"
$Header = ("Hosts with reboot required : {0}" -f @($Result).count)
$Comments = "The following hosts require a reboot."
$Display = "Table"
$Author = "Robert van den Nieuwendijk"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

Remove-Variable $Result
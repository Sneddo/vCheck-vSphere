# Start of Settings 
# End of Settings 

# Changelog
## 1.1 : ???
## 1.2 : Added Provider code

# Setup default strings
$pluginLang = DATA {
    ConvertFrom-StringData @'
		progressActivity = Gathering Host configuration issues
'@ }
# If a localized version is available, overwrite the defaults
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -bindingVariable pluginLang -ErrorAction SilentlyContinue

# Requires the vSphere provider for information
Import-Provider vSphere
$HostsViews = Get-vCheckvSphereObject "HostsViews"

$hostcialarms = @()
$i = 1
foreach ($HostsView in $HostsViews) {
	Write-Progress -ID 2 -Parent 1 -Activity $pluginLang.progressActivity -Status ($HostsView.Name) -PercentComplete (100*$i/($HostsViews.count))
	if ($HostsView.ConfigIssue) {           
		Foreach ($HostConfigIssue in $HostsView.ConfigIssue) {
			$Details = "" | Select-Object Name, Message
			$Details.Name = $HostsView.name
			$Details.Message = $HostConfigIssue.FullFormattedMessage
			$hostcialarms += $Details
		}
	}
	$i++
}
Write-Progress -ID 2 -Parent 1 -Activity $pluginLang.progressActivity -Status $global:lang.Complete -Completed

$hostcialarms | Sort-Object name

$Title = "Host Configuration Issues"
$Header = ("Host Configuration Issues: {0}" -f $hostcialarms.Count)
$Comments = "The following configuration issues have been registered against Hosts in vCenter"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

Remove-Variable hostcialarms
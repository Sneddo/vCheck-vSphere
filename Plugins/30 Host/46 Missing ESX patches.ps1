# Start of Settings 
# End of Settings 

# Note: This plugin needs the vCenter Update Manager PowerCLI snap-in installed
# https://communities.vmware.com/community/vmtn/automationtools/powercli/updatemanager
# (Current version 5.1 locks up in PowerShell v3; use "-version 2" when launching.)

# Changelog
## 1.1 : ???
## 1.2 : Added Provider code

$Results = @()

# Requires the vSphere provider for information
Import-Provider vSphere
if (Add-vCheckvSphereRequirement "Vmware.VumAutomation") {
	$VMH = Get-vCheckvSphereObject "Hosts"

	foreach($esx in $VMH){
		foreach($baseline in (Get-Compliance -Entity $esx -Detailed | where {$_.Status -eq "NotCompliant"})){
			$Results = $baseline.NotCompliantPatches |
			select @{N="Host";E={$esx.Name}},
			@{N="Baseline";E={$baseline.Baseline.Name}},Name,ReleaseDate,IdByVendor,
			@{N="KB";E={(Select-String "(?<url>http://[\w|\.|/]*\w{1})" -InputObject $_.Description).Matches[0].Groups['url'].Value}}
		}
	}
}

$Results

$Title = "Missing ESX(i) updates and patches"
$Header = ("Missing ESX(i) updates and patches: {0}" -f @($Results).Count)
$Comments = "The following updates and/or patches are not applied."
$Display = "Table"
$Author = "Luc Dekens"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

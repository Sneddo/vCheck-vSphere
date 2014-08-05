# Start of Settings 
# End of Settings 

# Requires vSphere Provider
Import-Provider vSphere

$clualarms = @()
foreach ($clusview in (Get-vCheckvSphereObject "ClustersViews")) {
	if ($clusview.ConfigIssue) {           
		$clualarms += $clusview.ConfigIssue | Select @{"name"="Cluster";Expression={$clusview.name}}, @{"name"="Message";Expression={$_.FullFormattedMessage}} 		
	}
}

$clualarms | Sort-Object Name

$Title = "Cluster Configuration Issues"
$Header = "Cluster(s) Config Issue(s): {count}"
$Comments = "The following alarms have been registered against clusters in vCenter"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

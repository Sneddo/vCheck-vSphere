# Start of Settings 
# End of Settings

# Requires vSphere Provider
Import-Provider vSphere

# Get all host profiles and corresponding cluster ID (don't really care about individual hosts at this stage!)
$HostProfiles = (Get-vCheckvSphereObject "HostProfiles") | Select Name, @{Name="ClusterID";Expression={$_.ExtensionData.Entity | ?{ $_.type -eq "ClusterComputeResource" }}}

(Get-vCheckvSphereObject "ClustersViews") | ?{($HostProfiles | Select -expandProperty ClusterID) -notcontains $_.moref } | Sort-Object Name | Select Name

$Title = "Clusters Without Host Profile attached"
$Header = "Clusters Without Host Profile attached"
$Comments = "The following clusters do not have a host profile attached"
$Display = "Table"
$Author = "John Sneddon"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

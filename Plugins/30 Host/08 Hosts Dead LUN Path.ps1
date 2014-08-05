# Start of Settings 
# End of Settings 

# Changelog
## 1.0 : Inital plugin release
## 1.1 : Alternate code in order to avoid usage of Get-ScsiLun for performance matter
## 1.2 : Added Provider code

# Requires the vSphere provider for information
Import-Provider vSphere

$deadluns = @()
foreach ($esxhost in (Get-vCheckvSphereObject "HostsViews" | where {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) {
	$esxhost | %{$_.config.storageDevice.multipathInfo.lun} | %{$_.path} | ?{$_.State -eq "Dead"} | %{
		$deadluns += New-Object PSObject -Property @{"VMHost" = $esxhost.Name; 
													 "Lunpath" = $_.Name;
													 "State" = $_.state }
	}
}
$deadluns

$Title = "Hosts Dead LUN Path"
$Header = ("Dead LunPath : {0}" -f @($deadluns).count)
$Comments = "Dead LUN Paths may cause issues with storage performance or be an indication of loss of redundancy"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

Remove-Variable deadluns
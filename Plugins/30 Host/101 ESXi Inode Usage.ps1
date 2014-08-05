# Start of Settings
# Set the ESXi filesystem free Inode threshold in percent
$InodeThreshold = 40
# End of Settings

# Changelog
## 1.1 : Added filter for connected Hosts only
## 1.2 : Added provider code

# Requires the vSphere provider for information
Import-Provider vSphere

$Result = @((Get-vCheckvSphereObject "Hosts") | Where-Object {$_.Version -match "^5\." -and ($_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance")} | Sort-Object | ForEach-Object {
	$EsxCli = Get-EsxCli -VMHost $_
	$EsxCli.system.visorfs.get() | Where-Object {[int]$_.FreeInodePercent -lt $InodeThreshold} | Add-Member -MemberType NoteProperty -Name VMHost -Value $_.Name -PassThru | Select-Object VMHost, FreeInodePercent, TotalInodes, UsedInodes
})
$Result

$Title = "ESXi Inode Exhaustion"
$Header = ("Hosts with few free Inodes (< {0}%) on the local ESXi visorfs: {1}" -f $InodeThreshold, @($Result).count)
$Comments = "The following hosts have an excessive amount of Inodes in use on the local ESXi filesystem. This can cause hosts to disconnect from vCenter and becoming completely unmanageable even locally, requiring a hard reboot. See <a href='http://kb.vmware.com/kb/2037798'>KB2037798</a> and <a href='http://kb.vmware.com/kb/1008643'>KB1008643</a>"
$Display = "Table"
$Author = "Matthias Koehler"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

Remove-Variable Result
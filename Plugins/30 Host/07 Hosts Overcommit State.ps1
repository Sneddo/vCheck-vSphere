# Start of Settings
# Return results in GB or MB?
$Units ="GB"
# End of Settings

# Changelog
## 1.1 : Initial plugin code
## 1.2 : ???
## 1.3 : ???
## 1.4 : Added Provider code

# Setup plugin-specific language table
$pLang = DATA {
ConvertFrom-StringData @' 
   pluginActivity = Checking overcommit state for hosts
'@ }

Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -BindingVariable pLang -ErrorAction SilentlyContinue

# Requires the vSphere provider for information
Import-Provider vSphere
$VMH = Get-vCheckvSphereObject "Hosts"
$VM = Get-vCheckvSphereObject "VMs"

$OverCommit = @()
$i = 0
Foreach ($VMHost in $VMH) {
	Write-Progress -ID 2 -Parent 1 -Activity $pLang.pluginActivity -Status $VMHost.Name -PercentComplete ((100*$i)/$VMH.Count)
	if ($VMMem) { Clear-Variable VMMem }
	$VM | ?{$_.VMHost.Name -eq $VMHost.Name} | Foreach {
		[INT]$VMMem += $_.MemoryMB
	}

	$UnitConvert = Invoke-Expression "1$Units/1MB"
	If ([Math]::Round(($VMMem - $VMHost.MemoryTotalMB), 0) -gt 0) {
		$OverCommitMB = [Math]::Round(($VMMem - $VMHost.MemoryTotalMB), 0)

		$OverCommit += New-Object PSObject -Property @{"Host" = $VMHost.Name;
							"TotalMem$Units" = [Math]::Round(($VMHost.MemoryTotalMB)/$UnitConvert,0);
							"TotalAssignedMem$Units" = [Math]::Round($VMMem/$UnitConvert,0);
							"TotalUsed$Units" = [Math]::Round(($VMHost.MemoryUsageMB)/$UnitConvert,0);
							"OverCommit$Units" = [Math]::Round($OverCommitMB/$UnitConvert, 0);
													}
		
	}
	$i++
}
Write-Progress -ID 2 -Parent 1 -Activity $plang.pluginActivity -Status $lang.Complete -Completed

$OverCommit | Select Host, "TotalMem$Units", "TotalAssignedMem$Units", "TotalUsed$Units", "OverCommit$Units"

$Title = "Hosts Overcommit state"
$Header = ("Hosts overcommitting memory : {0}" -f @($OverCommit).count)
$Comments = "Overcommitted hosts may cause issues with performance if memory is not issued when needed, this may cause ballooning and swapping"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

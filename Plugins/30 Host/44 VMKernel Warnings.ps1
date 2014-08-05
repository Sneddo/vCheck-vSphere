# Start of Settings
# Disabling displaying Google/KB links in order to have wider message column
$simpleWarning = $true
# End of Settings

# Changelog
## 1.1 : ???
## 1.2 : ???
## 1.3 : Added Provider code

# Requires the vSphere provider for information
Import-Provider vSphere
$HostsViews = Get-vCheckvSphereObject "HostsViews"

$VMKernelWarnings = @()
foreach ($VMHost in ($HostsViews)){
	$product = $VMHost.config.product.ProductLineId
	if ($product -eq "embeddedEsx" -and $VIVersion -lt 5){
		$Warnings = (Get-Log -vmhost ($VMHost.name) -Key messages -ErrorAction SilentlyContinue).entries |where {$_ -match "warning" -and $_ -match "vmkernel"}
	} else {
		$Warnings = (Get-Log -VMHost ($VMHost.Name) -Key vmkernel -ErrorAction SilentlyContinue).Entries | where {$_ -match "warning"}
	}
	if ($Warnings -ne $null) {
		$VMKernelWarning = @()
		$Warnings | Foreach {
			if ($simpleWarning) {
				$Details = "" | Select-Object VMHost, Message
				$Details.VMHost = $VMHost.Name
				$Details.Message = $_
			} else {
				$Details = "" | Select-Object VMHost, Message, Length, KBSearch, Google
				$Details.VMHost = $VMHost.Name
				$Details.Message = $_
				$Details.Length = ($Details.Message).Length
				$Details.KBSearch = "<a href='http://kb.vmware.com/selfservice/microsites/search.do?searchString=$($Details.Message)&sortByOverride=PUBLISHEDDATE&sortOrder=-1' target='_blank'>Click Here</a>"
				$Details.Google = "<a href='http://www.google.co.uk/search?q=$($Details.Message)' target='_blank'>Click Here</a>"
			}
			$VMKernelWarning += $Details
		}
		$VMKernelWarnings += $VMKernelWarning | Sort-Object -Property Length -Unique |select VMHost, Message, KBSearch, Google			
	}
}	
			
$VMKernelWarnings | Sort-Object Message -Descending

$Title = "VMKernel Warnings"
$Header = ("ESX/ESXi VMKernel Warnings: {0}" -f @($VMKernelWarnings).Count)
$Comments = "The following VMKernel issues were found, it is suggested all unknown issues are explored on the VMware Knowledge Base. Use the below links to automatically search for the string"
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

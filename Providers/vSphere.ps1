<#
I should add a header...

#>
################################################################################
#                               Initialization                                 #
################################################################################
# Init Provider hashtable
$global:Providers.Add("vSphere", @{"Data" = @{}})

# Load default strings
$pLang = DATA {    
ConvertFrom-StringData @' 
   connReuse = Re-using connection to VI Server
   connOpen  = Connecting to VI Server
   connError = Unable to connect to vCenter, please ensure you have altered the vCenter server address correctly. To specify a username and password edit the connection string in the file $GlobalVariables
   custAttr  = Adding Custom properties
   collectVM = Collecting VM Objects
   collectHost = Collecting VM Host Objects
   collectCluster = Collecting Cluster Objects
   collectDatastore = Collecting Datastore Objects
   collectDVM = Collecting Detailed VM Objects
   collectTemplate = Collecting Template Objects
   collectDVIO = Collecting Detailed VI Objects
   collectAlarm = Collecting Detailed Alarm Objects
   collectDHost = Collecting Detailed VMHost Objects
   collectDCluster = Collecting Detailed Cluster Objects
   collectDDatastore = Collecting Detailed Datastore Objects
   collectDDatastoreCluster = Collecting Detailed Datastore Cluster Objects
   requirementNotFound = Requirement not found on this host: {0}
'@ }

# Add Provider strings to global provider variable
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -FileName Provider-vSphere -BindingVariable pLang -ErrorAction SilentlyContinue
$global:Providers.vSphere.Add("lang",$pLang)
Remove-Variable -Name pLang

################################################################################
#                              REQUIRED FUNCTIONS                              #
################################################################################
# This section defines required functions for each provider:
# Connect-vCheck<<providerName>> - Initialise provider
# Disconnect-vCheck<<providerName>> - cleanup provider
# Get-vCheck<<providerName>>Object - Get a vCheck Object

function global:Connect-vCheckvSphere() {
	# Adding PowerCLI core snapin
	if (!(Get-PSSnapin -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
		Add-PSSnapin VMware.VimAutomation.Core
	}
	$VIServer = $script:Server
	$OpenConnection = $global:DefaultVIServers | where { $_.Name -eq $VIServer }
	if($OpenConnection.IsConnected) {
		Write-CustomOut $global:Providers.vSphere.lang.connReuse
		$VIConnection = $OpenConnection
	} else {
		Write-CustomOut $global:Providers.vSphere.lang.connOpen
		$VIConnection = Connect-VIServer $VIServer
	}

	if (-not $VIConnection.IsConnected) {
		Write-Error $global:Providers.vSphere.lang.connError
	}
}

<# Disconnect vCenter connection #>
function global:Disconnect-vCheckvSphere() {
	if ($VIConnection) {
		$VIConnection | Disconnect-VIServer -Confirm:$false
	}
	
	# Remove vSphere cache
	$global:Providers.Remove("vSphere")
	# Run garbage collector to free memory
	[gc]::Collect()
}

<# Get a vCheck Object. On susequent requests, return a cached value unless explicitly told not to #>
function global:Get-vCheckvSphereObject  {
	param ([string]$ObjName, [switch]$force)

	# if force is set, retrieve the object again by clearing the cached copy
	if ($force) {
		$global:Providers.vSphere.Data.$ObjName = $null
	}
	# If we do not have cashed data, recalculate
	if ($global:Providers.vSphere.Data.$ObjName -eq $null) {
		switch ($ObjName) {
			"ServiceInstance" { Write-CustomOut $pLang.collectDVIO
							    $ServiceInstance = get-view ServiceInstance }
			"AlarmManager"	{ $ServiceInstance = Get-vCheckvSphereObject ServiceInstance
							  Write-CustomOut $pLang.collectAlarm
							  $alarmMgr = get-view $ServiceInstance.Content.alarmManager }
			"ClusterViews"	{ Write-CustomOut $pLang.collectDCluster
							  $value = Get-View -ViewType ClusterComputeResource }
			"Hosts"  		{ Write-CustomOut $global:Providers.vSphere.lang.collectHost;
							  $value = (Get-VMHost | Sort Name);  }
			"HostsViews"	{ Write-CustomOut $global:Providers.vSphere.lang.collectDHost;
							  $value = Get-View -ViewType hostsystem }
			"VMs" 			{ Write-CustomOut $global:Providers.vSphere.lang.collectVM
							  $value = Get-VM | Sort Name }

		}
		$global:Providers.vSphere.Data.Add($ObjName, $value)
	}
	return ($global:Providers.vSphere.Data.$ObjName)
}

################################################################################
#                         vSphere Provider Functions                           #
################################################################################
# This section contains any global functions for this provider to save on code 
# duplication
function Add-vCheckvSphereRequirement ([string]$Name) {
	if ((Get-PSSnapin -name $Name -erroraction silentlycontinue) -or ((Get-Module $Name).Count -gt 0)) {
		return $true
	}
	
	if ((Get-PSSnapin -Registered | Where {$_.name -eq $Name }).Count -gt 0) {
		Add-PSSnapin $Name
		return $true
	}
	
	if ((Get-Module -ListAvailable | Where {$_.name -eq $Name }).Count -gt 0) {
		Import-Module $Name
	}
	
	# if we get this far, the requirement is not available
	Write-Warning $global:Providers.vSphere.lang.requirementNotFound -f $Name
	return $false
}

function Get-VMLastPoweredOffDate {
  param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl] $vm)
  process {
    $Report = "" | Select-Object -Property Name,LastPoweredOffDate
     $Report.Name = $_.Name
    $Report.LastPoweredOffDate = (Get-VIEvent -Entity $vm | `
      Where-Object { $_.Gettype().Name -eq "VmPoweredOffEvent" } | `
       Select-Object -First 1).CreatedTime
     $Report
  }
}

function Get-VMLastPoweredOnDate {
  param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl] $vm)

  process {
    $Report = "" | Select-Object -Property Name,LastPoweredOnDate
     $Report.Name = $_.Name
    $Report.LastPoweredOnDate = (Get-VIEvent -Entity $vm | `
      Where-Object { $_.Gettype().Name -eq "VmPoweredOnEvent" } | `
       Select-Object -First 1).CreatedTime
     $Report
  }
}
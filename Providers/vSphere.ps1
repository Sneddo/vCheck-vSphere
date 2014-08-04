# Add Provider strings to global lang variable
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -FileName Provider-vSphere -BindingVariable pLang
$global:lang+=$pLang

################################################################################
#                              REQUIRED FUNCTIONS                              #
################################################################################
# This section defines required functions for each provider:
# Connect-vCheck<<providerName>> - Initialise provider
# Disconnect-vCheck<<providerName>> - cleanup provider
# Get-vCheck<<providerName>>Object - Get a vCheck Object

function Connect-vCheckvSphere() {
	# Adding PowerCLI core snapin
	if (!(get-pssnapin -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
		add-pssnapin VMware.VimAutomation.Core
	}
	$VIServer = $script:Server
	$OpenConnection = $global:DefaultVIServers | where { $_.Name -eq $VIServer }
	if($OpenConnection.IsConnected) {
		Write-CustomOut $global:lang.connReuse
		$VIConnection = $OpenConnection
	} else {
		Write-CustomOut $global:lang.connOpen
		$VIConnection = Connect-VIServer $VIServer
	}

	if (-not $VIConnection.IsConnected) {
		Write-Error $global:lang.connError
	}
}

<# Disconnect vCenter connection #>
function Disconnect-vCheckvSphere() {
	if ($VIConnection) {
		$VIConnection | Disconnect-VIServer -Confirm:$false
	}
}

<# Get a vCheck Object. On susequent requests, return a cached value unless explicitly told not to #>
function global:Get-vCheckvSphereObject  {
	param ([string]$ObjName, [switch]$force)

	# if force is set, retrieve the object again by clearing the cached copy
	if ($force) {
		Remove-Variable -scope global -name $ObjName -ErrorAction SilentlyContinue
	}
	
	# If we already have this object, return the cached value
	if (Test-Path variable:global:$objName) {
		return (Get-Variable -Scope Global -Name $objName -ValueOnly)
	}
	else{
		switch ($ObjName) {
				"Hosts"  { Write-CustomOut $global:lang.collectHost;
						  $value = (Get-VMHost | Sort Name);  }
			"HostsViews" { Write-CustomOut $global:lang.collectDHost;
						  $value = Get-View -ViewType hostsystem }
		}
		Set-Variable -Scope Global -Name $objName -Value $value
	}
	return $value
}

################################################################################
#                              PROVIDER FUNCTIONS                              #
################################################################################
# This section contains any global functions for this provider to save on code 
# duplication
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
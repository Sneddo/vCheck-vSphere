# Start of Settings 
# End of Settings 

# Changelog
## 1.1 : ???
## 1.2 : ???
## 1.3 : Added Provider code

# Requires the vSphere provider for information
Import-Provider vSphere
$alarmMgr = Get-vCheckvSphereObject "AlarmManager"
$HostsViews = Get-vCheckvSphereObject "HostsViews"

$alarms = $alarmMgr.GetAlarm($null) | select value, @{N="name";E={(Get-View -Id $_).Info.Name}}
$hostsalarms = @()
foreach ($HostsView in $HostsViews){
	if ($HostsView.TriggeredAlarmState){
		$hostsTriggeredAlarms = $HostsView.TriggeredAlarmState
		Foreach ($hostsTriggeredAlarm in $hostsTriggeredAlarms){
			$Details = "" | Select-Object Object, Alarm, Status, Time
			$Details.Object = $HostsView.name
			$Details.Alarm = ($alarms | Where {$_.value -eq ($hostsTriggeredAlarm.alarm.value)}).name
			$Details.Status = $hostsTriggeredAlarm.OverallStatus
			$Details.Time = $hostsTriggeredAlarm.time
			$hostsalarms += $Details
		}
	}
}

@($hostsalarms | Sort-Object Object)
    
$Title = "Host Alarms"
$Header = ("Host Alarm(s): {0}" -f @($hostsalarms).Count)
$Comments = "The following alarms have been registered against hosts in vCenter"
$Display = "Table"
$Author = "Alan Renouf"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

$TableFormat = @{"Status" = @(@{ "-eq 'yellow'"     = "Row,class|warning"; },
							  @{ "-eq 'red'"     = "Row,class|critical" })
				}

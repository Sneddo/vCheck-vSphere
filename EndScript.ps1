# Everything in this script will run at the end of vCheck
Remove-Variable -name lang -scope global
[gc]::Collect()
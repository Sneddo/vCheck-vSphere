# Everything in this script will run at the end of vCheck
Remove-Variable ReportResources, lang -ErrorAction SilentlyContinue
[gc]::Collect()
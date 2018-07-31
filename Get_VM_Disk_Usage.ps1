Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu
$totalStorage = ""
$machines = Get-Content 'C:\Admin Scripts\Inputs\important_VMs.txt'


foreach($thisVM in $machines){


$currentStorage = Get-VM -Name $thisVM | Select-Object -ExpandProperty UsedSpaceGB
$currentStorage = [math]::Round($currentStorage)


[int]$currentStorage = [convert]::ToInt32($currentStorage, 10)

[int]$totalStorage += [int]$currentStorage


Add-Content C:\Outputs\dater.csv $currentStorage

}

$totalStorage

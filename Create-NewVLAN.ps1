Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$hosts = Get-VMHost

foreach($newhost in $hosts){
Get-VMHost -Name $newHost | Get-VirtualSwitch -Name “vSwitch0" | New-VirtualPortGroup -Name “SparkNet” -VLanId 195
}

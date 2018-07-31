Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$allHosts = Get-VMHost

foreach($esxihost in $allHosts){

New-Datastore -VMHost $esxihost -Name "Sysshare ISOs" -Path "/root_vdm_1/software/Install/Operating Systems" -NfsHost sysshare.cs.odu.edu -ReadOnly -Nfs

}

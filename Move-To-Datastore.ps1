Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
$VIServer="vcenter.cs.odu.edu"
#Connect-VIServer $VIServer -Credential (Import-clixml "C:\Admin Scripts\ESXi\vcenter_admin_creds.clixml")
Connect-VIServer $VIServer

$VMs = Get-datastore | Where {$_.name -like '*ECS EMC TARGET*'} | Get-VM



Foreach ($VM in $VMs){


     Write-Host "Currently trying to move VM: $VM.Name"
     Move-VM -Datastore "ECS-All-Flash" -VM $VM | Out-Null




}
Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu -Credential (Import-clixml "C:\Admin Scripts\ESXi\vcenter_admin_creds_2.clixml")

$List_of_VMs = Get-VM


ForEach($vm in $List_of_VMs){

    
    $clone_name = $vm.Name + "_dvx_clone"
    if($vm.Name -like "*dvx*"){ continue }
    if($vm.Name -like "*dat*"){ continue }

    
    New-VM -Name $clone_name -VM $vm -Datastore 'dvx-data-2-Datastore1' -VMHost 'dvx-compute-2.cs.odu.edu' -Location 'Datrium' -RunAsync

}
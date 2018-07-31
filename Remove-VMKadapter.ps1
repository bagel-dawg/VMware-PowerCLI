Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$all_hosts = Get-VMHost 

$esxi_host = "d-esxi-9.cs.odu.edu"

$portgroups_to_delete = "Spark Private Network","vMotion Test", "4/5Net", "Management"
$portgroups_to_delete = Get-VirtualPortGroup -VMHost $esxi_host

#foreach ($esxi_host in $all_hosts){


    foreach($portgroup in $portgroups_to_delete){
    
        $vmks = Get-VirtualPortGroup -VMHost $esxi_host -Name $portgroup
    
        foreach($vmk in $vmks){
            if($vmk.Name -eq "Management Network"){ continue; }
            if($vmk.Name -eq "Consultant Isolated Network"){ continue; }
            $delete_me = Get-VMHostNetworkAdapter -vmhost $esxi_host | Where {$_.Portgroupname -eq $vmk.Name}
            $delete_me | Remove-VMHostNetworkAdapter -Confirm:$false 
            $vmk | Remove-VirtualPortGroup -Confirm:$false
        
        }    
    }
#}


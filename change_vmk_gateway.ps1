Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$all_hosts = Get-VMHost 

foreach ($esxi_host in $all_hosts){


    #New-VMHostNetworkAdapter -VMHost $esxi_host -PortGroup "iSCSI Traffic II" -VirtualSwitch vSwitch0
    $vmks = Get-VirtualPortGroup -VMHost $esxi_host -VirtualSwitch vSwitch0 -Name "*vMotion*"
    
    foreach($vmk in $vmks){
    
        if(($vmk.Name -like "*vMotion I*") -or ($vmk.Name -like "*vMotion II*")){

            $vmk.Name
        
        }
    
    }    

}


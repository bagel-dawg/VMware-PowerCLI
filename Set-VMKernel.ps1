Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$all_hosts = Get-VMHost 

foreach ($esxi_host in $all_hosts){


    #New-VMHostNetworkAdapter -VMHost $esxi_host -PortGroup "iSCSI Traffic II" -VirtualSwitch vSwitch0
    $vmks = Get-VirtualPortGroup -VMHost $esxi_host -VirtualSwitch vSwitch0 -Name "*vMotion*"
    
    foreach($vmk in $vmks){
    
        if(($vmk.Name -notlike "vMotion I") -and ($vmk.Name -notlike "vMotion II")){

            if($vmk.Name -like "vMotion Traffic II"){
                
                $vmk | Remove-VirtualPortGroup -Confirm:$false
                New-VMHostNetworkAdapter -VMHost $esxi_host -VirtualSwitch vSwitch0 -PortGroup "vMotion II" -VMotionEnabled $true -confirm:$false
                
                $vm_kernel = Get-VirtualPortGroup -VMHost $esxi_host -VirtualSwitch vSwitch0 -Name "vMotion II"
                $vm_kernel | Set-VirtualPortGroup -Name "vMotion II" -VLanId 457
            
            }

            if($vmk.Name -like "vMotion Traffic I"){

                $vmk | Remove-VirtualPortGroup -Confirm:$false
                New-VMHostNetworkAdapter -VMHost $esxi_host -VirtualSwitch vSwitch0 -PortGroup "vMotion I" -VMotionEnabled $true -confirm:$false
                
                $vm_kernel = Get-VirtualPortGroup -VMHost $esxi_host -VirtualSwitch vSwitch0 -Name "vMotion I"
                $vm_kernel | Set-VirtualPortGroup -Name "vMotion I" -VLanId 457
            
            }
        
        }
    
    }    

}


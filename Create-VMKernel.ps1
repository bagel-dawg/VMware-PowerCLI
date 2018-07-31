Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$all_hosts = Get-VMHost 

foreach ($esxi_host in $all_hosts){


    #New-VMHostNetworkAdapter -VMHost $esxi_host -PortGroup "iSCSI Traffic II" -VirtualSwitch vSwitch0
    $vm_kernel = Get-VirtualPortGroup -VMHost $esxi_host -VirtualSwitch vSwitch0 -Name "iSCSI Traffic II"

    $vm_kernel | Set-VirtualPortGroup -Name "iSCSI Traffic II" -VLanId 51

}

Get-Module -ListAvailable VMware* | Import-Module
Connect-VIServer vcenter.cs.odu.edu


$all_hosts = Get-VMHost

$gateway_to_add = "192.168.51.254"
$interface_names = "51-iSCSI-Interfaces*"


foreach($esxiHost in $all_hosts){


    $vmkernels_to_change = Get-VMHostNetworkAdapter -VMHost $esxiHost -VMKernel | Where {$_.PortGroupName -like $interface_names}
    
    foreach($vmkernel in $vmkernels_to_change){

        $ip = $vmkernel.IP
        $device_name = $vmkernel.DeviceName
        $netmask = "255.255.255.0"

        $esxcli = Get-EsxCli -VMHost $esxiHost -V2
        $arguments = $esxcli.network.ip.interface.ipv4.set.CreateArgs()
        $arguments.netmask = $netmask
        $arguments.gateway = $gateway_to_add
        $arguments.type = "static"
        $arguments.interfacename = $device_name
        $arguments.ipv4 = $ip
        $esxcli.network.ip.interface.ipv4.set.Invoke($arguments) 
    
    
    }
}

Disconnect-VIServer -Server vcenter.cs.odu.edu -Confirm:$false
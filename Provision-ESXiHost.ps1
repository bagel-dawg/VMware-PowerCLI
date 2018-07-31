Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$HostCredentials = (Get-Credential -Username root -Message "Enter the root password for the ESXi Host.")
$newHost = Read-Host "Enter FQDN of new host"
$vMotionI = Read-Host "Enter the vMotion I Interface IP: "
$vMotionII = Read-Host "Enter the vMotion II Interface IP: "
$iscsiI = Read-Host "Enter the iSCSI I Interface IP: "
$iscsiII = Read-Host "Enter the iSCSI II Interface IP: "


#Add the host to vcenter

if($newHost -like "e-esxi-*"){

    Add-VMHost $newHost -Location 'ECS Cluster' -Credential $HostCredentials -Force:$true

}elseif($newHost -like "d-esxi-*"){

    Add-VMHost $newHost -Location 'Dragas Cluster' -Credential $HostCredentials -Force:$true

}else{

    Add-VMHost $newHost -Location 'Computer Science' -Credential $HostCredentials -Force:$true

}



#Throws it into maintenance mode
Get-VMHost -Name $newHost | Set-VMHost -State Maintenance


##vSwitch1 port groups
Get-VMHost -Name $newHost | New-VirtualSwitch -Name "vSwitch1"
Get-VMHost -Name $newHost | Get-VirtualSwitch -Name “vSwitch1" | New-VirtualPortGroup -Name "Consultant Isolated Network"

#Make sure both active NICs are added to vSwitch0
$connectedNICs = Get-VMHost -Name $newHost | Get-VMHostNetworkAdapter -Physical | Where-Object {$_.BitRatePerSec -gt 1000}


$vds = Get-VDSwitch -Name Distributed_vSwitch_0

#Add host to vDS
$vds | Add-VDSwitchVMHost -VMHost $newHost

$managementNic = Get-VMHostNetworkAdapter -VMHost $newHost -PortGroup "Management Network"

$vds | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $connectedNICs -VMHostVirtualNic $managementNic -VirtualNicPortgroup "187-Management-Network" -Confirm:$false


#Create vmks and add to vDS Portgroup
New-VMHostNetworkAdapter -VMHost $newHost -VirtualSwitch "Distributed_vSwitch_0" -PortGroup "457-vMotion-Interfaces-1" -IP $vMotionI -SubnetMask 255.255.255.0
New-VMHostNetworkAdapter -VMHost $newHost -VirtualSwitch "Distributed_vSwitch_0" -PortGroup "457-vMotion-Interfaces-2" -IP $vMotionII -SubnetMask 255.255.255.0
New-VMHostNetworkAdapter -VMHost $newHost -VirtualSwitch "Distributed_vSwitch_0" -PortGroup "51-iSCSI-Interfaces-1" -IP $iscsiI -SubnetMask 255.255.255.0
New-VMHostNetworkAdapter -VMHost $newHost -VirtualSwitch "Distributed_vSwitch_0" -PortGroup "51-iSCSI-Interfaces-2" -IP $iscsiII -SubnetMask 255.255.255.0


#Enabled vMotion on VMKernel
Get-VMHost -Name $newHost | Get-VMHostNetworkAdapter -VMKernel | Where {$_.PortGroupName -like "457-vMotion-Interfaces-*"} | Set-VMHostNetworkAdapter -VMotionEnabled $true -Confirm:$false

#Override Default Gateways
$vMotionVMKs = Get-VMHostNetworkAdapter -VMHost $newHost -VMKernel | Where {$_.PortGroupName -like "457-vMotion-Interfaces-*"}
    foreach($vmkernel in $vMotionVMKs){

        $ip = $vmkernel.IP
        $device_name = $vmkernel.DeviceName
        $netmask = "255.255.255.0"
        $gateway_to_add = "172.18.10.254"

        $esxcli = Get-EsxCli -VMHost $newhost -V2
        $arguments = $esxcli.network.ip.interface.ipv4.set.CreateArgs()
        $arguments.netmask = $netmask
        $arguments.gateway = $gateway_to_add
        $arguments.type = "static"
        $arguments.interfacename = $device_name
        $arguments.ipv4 = $ip
        $esxcli.network.ip.interface.ipv4.set.Invoke($arguments) 
    
    
    }


$iSCSIVMKs = Get-VMHostNetworkAdapter -VMHost $newHost -VMKernel | Where {$_.PortGroupName -like "51-iSCSI-Interfaces-*"}
    foreach($vmkernel in $iSCSIVMKs){

        $ip = $vmkernel.IP
        $device_name = $vmkernel.DeviceName
        $netmask = "255.255.255.0"
        $gateway_to_add = "192.168.51.254"

        $esxcli = Get-EsxCli -VMHost $newhost -V2
        $arguments = $esxcli.network.ip.interface.ipv4.set.CreateArgs()
        $arguments.netmask = $netmask
        $arguments.gateway = $gateway_to_add
        $arguments.type = "static"
        $arguments.interfacename = $device_name
        $arguments.ipv4 = $ip
        $esxcli.network.ip.interface.ipv4.set.Invoke($arguments) 
    
    
    }
    
##End networking configuration




#Unmount the local datastore and delete it.
$datastore =  Get-Datastore -VMHost $newHost | Where { $_.Name -Like "datastore1*" }
Remove-Datastore -VMHost $newHost -Datastore $datastore -Confirm:$false


#Logs all syslog messages to logstash/elastisearch
#Set-VMHostSysLogServer -SysLogServer 172.18.8.125:5140 -VMHost $newHost

#Set NTP Servers
Get-VMHost -Name $newHost | Add-VMHostNtpServer -NtpServer 172.18.8.3 -Confirm:$False
Get-VMHost -Name $newHost | Add-VMHostNtpServer -NtpServer 172.18.8.4 -Confirm:$False


#Start SSH and hide the warning for it being enabled. Automatically start and stop with host.
Get-VMHost -Name $newHost | Get-VMHostService | Where { $_.Key -eq "TSM-SSH" } | Start-VMHostService
Set-VMHostAdvancedConfiguration -VMHost $newHost -Name UserVars.SuppressShellWarning -Value 1
Get-VMHostService -VMHost $newHost | Where-Object { $_.Key -eq "TSM-SSH"} | Set-VMHostService -Policy "Automatic"




New-Datastore -VMHost $newHost -Name "ecs-all-flash-1" -Path "/ecs_vmware_1" -NfsHost ecs-vmware-datastore.cs.odu.edu -Nfs
New-Datastore -VMHost $newHost -Name "ecs-all-flash-2" -Path "/ecs_vmware_2" -NfsHost ecs-vmware-datastore.cs.odu.edu -Nfs
New-Datastore -VMHost $newHost -Name "dgs-all-flash-1" -Path "/dgs_vmware_1" -NfsHost dgs-vmware-datastore.cs.odu.edu -Nfs
New-Datastore -VMHost $newHost -Name "dgs-all-flash-2" -Path "/dgs_vmware_2" -NfsHost dgs-vmware-datastore.cs.odu.edu -Nfs

New-Datastore -VMHost $newHost -Name "ecs-consultant-1" -Path "/ecs_vmware_consultant_1" -NfsHost ecs-vmware-datastore.cs.odu.edu -Nfs
New-Datastore -VMHost $newHost -Name "dgs-consultant-1" -Path "/dgs_vmware_consultant_1" -NfsHost dgs-vmware-datastore.cs.odu.edu -Nfs

New-Datastore -VMHost $newHost -Name "ISOs" -Path "/root_vdm_1/software/Install/Operating Systems" -NfsHost sysshare.cs.odu.edu -ReadOnly -Nfs

#Rescan for datastores and refresh storage information
Write-Host "Sleeping for 30 second to finish scanning for datstores.."
Get-VMHostStorage -VMHost $newHost -RescanAllHba -RescanVmfs -Refresh


#All done with the configuration parts. Return to regular state.
Get-VMHost -Name $newHost | Set-VMHost -State Connected

Disconnect-VIServer -Server vcenter.cs.odu.edu -Confirm:$false

#Create the nagios user and assign the readonly permission
Connect-VIServer $newHost -Credential $HostCredentials
    New-VMHostAccount -Id nagios -Password '######'
    $RootFolder = Get-Folder -Name root
    New-VIPermission -Entity $RootFolder -Principal nagios -Role ReadOnly -Propagate:$true
Disconnect-VIServer -Server $newHost -Confirm:$false

Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

Function Get-DatastoreMountInfo {
    #function copied from https://communities.vmware.com/docs/DOC-18008
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$true)]
        $Datastore
    )
    Process {
        $AllInfo = @()
        if (-not $Datastore) {
            $Datastore = Get-Datastore
        }
        Foreach ($ds in $Datastore) {  
            if ($ds.ExtensionData.info.Vmfs) {
                $hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].diskname
                if ($ds.ExtensionData.Host) {
                    $attachedHosts = $ds.ExtensionData.Host
                    Foreach ($VMHost in $attachedHosts) {
                        $hostview = Get-View $VMHost.Key
                        $hostviewDSState = $VMHost.MountInfo.Mounted
                        $StorageSys = Get-View $HostView.ConfigManager.StorageSystem
                        $devices = $StorageSys.StorageDeviceInfo.ScsiLun
                        Foreach ($device in $devices) {
                            $Info = '' | Select Datastore, VMHost, Lun, Mounted, State
                            if ($device.canonicalName -eq $hostviewDSDiskName) {
                                $hostviewDSAttachState = ''
                                if ($device.operationalState[0] -eq "ok") {
                                    $hostviewDSAttachState = "Attached"                        
                                } elseif ($device.operationalState[0] -eq "off") {
                                    $hostviewDSAttachState = "Detached"                        
                                } else {
                                    $hostviewDSAttachState = $device.operationalstate[0]
                                }
                                $Info.Datastore = $ds.Name
                                $Info.Lun = $hostviewDSDiskName
                                $Info.VMHost = $hostview.Name
                                $Info.Mounted = $HostViewDSState
                                $Info.State = $hostviewDSAttachState
                                $AllInfo += $Info
                            }
                        }
                         
                    }
                }
            }
        }
        $AllInfo
    }
}
Function Detach-Datastore {
    #function based on code found here https://communities.vmware.com/docs/DOC-18008
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$true)]
        $Datastore
    )
    Process {
        if (-not $Datastore) {
            Write-Host "No Datastore defined as input"
            Exit
        }
        Foreach ($ds in $Datastore) {
            $hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].Diskname
            if ($ds.ExtensionData.Host) {
                $attachedHosts = $ds.ExtensionData.Host
                Foreach ($VMHost in $attachedHosts) {
                    $hostview = Get-View $VMHost.Key
                    $StorageSys = Get-View $HostView.ConfigManager.StorageSystem
                    $devices = $StorageSys.StorageDeviceInfo.ScsiLun
                    Foreach ($device in $devices) {
                        if ($device.canonicalName -eq $hostviewDSDiskName) {
                            #If the device is attached then detach it (I added this to the function to prevent error messages in vcenter when running the script)
                            if ($device.operationalState[0] -eq "ok") { 
                                $LunUUID = $Device.Uuid
                                Write-Host "Detaching LUN $($Device.CanonicalName) from host $($hostview.Name)..."
                                $StorageSys.DetachScsiLun($LunUUID);
                            }
                            #If the device isn't attached then skip it (I added this to the function to prevent error messages in vcenter when running the script)
                            else {
                                Write-Host "LUN $($Device.CanonicalName) is not attached on host $($hostview.Name)..."
                            }
                        }
                    }
                }
            }
        }
    }
}
Function Unmount-Datastore {
    #function based on code found here https://communities.vmware.com/docs/DOC-18008
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$true)]
        $Datastore
    )
    Process {
        if (-not $Datastore) {
            Write-Host "No Datastore defined as input"
            Exit
        }
        Foreach ($ds in $Datastore) {
            $hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].Diskname
            if ($ds.ExtensionData.Host) {
                $attachedHosts = $ds.ExtensionData.Host
                Foreach ($VMHost in $attachedHosts) {
                    $hostview = Get-View $VMHost.Key
                    $mounted = $VMHost.MountInfo.Mounted
                    #If the device is mounted then unmount it (I added this to the function to prevent error messages in vcenter when running the script)
                    if ($mounted -eq $true) {
                        $StorageSys = Get-View $HostView.ConfigManager.StorageSystem
                        Write-Host "Unmounting VMFS Datastore $($DS.Name) from host $($hostview.Name)..."
                        $StorageSys.UnmountVmfsVolume($DS.ExtensionData.Info.vmfs.uuid);
                    }
                    #If the device isn't mounted then skip it (I added this to the function to prevent error messages in vcenter when running the script)
                    else {
                        Write-Host "VMFS Datastore $($DS.Name) is already unmounted on host $($hostview.Name)..."
                    }
                }
            }
        }
    }
}
#VARIABLES
#Parameters 
$DSNames = "ISOs"

#SCRIPT MAIN
clear

Foreach($DSName in $DSNames){
$datastore = Get-Datastore -Name $DSName
$CanonicalName = $datastore.ExtensionData.Info.Vmfs.Extent[0].DiskName
$GoAhead = "yes"
if ($GoAhead -eq "yes" -or $GoAhead -eq "y" -or $GoAhead -eq "Y") {
    Write-Host "Unmounting datastore $DSName..."   
    $datastore | Unmount-Datastore
    Write-Host "Detaching datastore $DSName from hosts..."
    $datastore | Detach-Datastore
}
$DSName
$CanonicalName
}
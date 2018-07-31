Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$DSNames = "DGS EMC CONSULTANT TARGET", "ECS EMC CONSULTANT TARGET", "DGS EMC TARGET 1", "DGS EMC TARGET 2", "DGS EMC TARGET 3", "DGS EMC TARGET 4", "DGS EMC TARGET 5", "ECS EMC TARGET 1", "ECS EMC TARGET 2", "ECS EMC TARGET 3", "ECS EMC TARGET 4", "ECS EMC TARGET 5"

$all_hosts = Get-VMHost

#SCRIPT MAIN
clear

Foreach($vmhost in $all_hosts){

    Foreach($DSName in $DSNames){

        $datastore = Get-Datastore -Name $DSName
        Remove-Datastore -Datastore $datastores -VMHost $vmhost
        
    }
}
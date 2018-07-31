Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$VMsWithDatastore = Get-Cluster "ECS Cluster" | Get-VM | Select Name,VMHost,@{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))}}
$VMsWithDatastore | Sort-Object -Property Name
$OutFile = "C:\temp\vms_to_move.txt"


Foreach($vm in $VMsWithDatastore){

    $datastoreString = "DGS EMC TARGET*"
    $vmhostString = "e-esxi*"

    if(($vm.VMhost -like $vmhostString) -and ($vm.Datastore -like $datastoreString)){

      $stringToWrite =  $vm.Name +  " , "  + $vm.VMHost + " , "  + $vm.Datastore  + " - Needs to be moved"
      $stringToWrite | Out-File -FilePath $OutFile -Append
    
    
    }

    $datastoreString = "ECS EMC TARGET*"
    $vmhostString = "d-esxi*"

    if(($vm.VMhost -like $vmhostString) -and ($vm.Datastore -like $datastoreString)){

      $stringToWrite =  $vm.Name +  " , "  + $vm.VMHost + " , "  + $vm.Datastore  + " - Needs to be moved"
      $stringToWrite | Out-File -FilePath $OutFile -Append
    
    
    }



}



$VMsWithDatastore | Out-GridView

Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
$VIServer="vcenter.cs.odu.edu"
Connect-VIServer $VIServer -Username nagiosScript -Password '#####'

$ExcludedFolders = "Development" , "dev.cs.odu.edu", "Consultants", "Courses", "Clusters", "Discovered virtual machine", "OS Deployment Testing", "CRTC", "Delete Me", "Grad VMs"

$totalUsed = 0
$totalProvisioned = 0

$AllVMs = Get-VM -Location "Production"

Write-Host "Total VMs in Cluster: "  $AllVMs.Count

ForEach($folder in $ExcludedFolders){

    $VMs += Get-VM -Location $folder  #, ProvisionedSpaceGB, UsedSpaceGB
    

}



$newrange = Compare-Object $AllVMs $VMs | Where-Object {$_.SideIndicator -eq '<='}
Write-Host "Total VMs in Excluded Folders: " $VMs.Count
Write-Host "Total VMs to Backup: " $newrange.Count

Read-Host "Press Enter to continue..."

ForEach($backupTarget in $newrange){


    
    $currentVM = Get-VM -Name $backupTarget.InputObject | Select Name, ProvisionedSpaceGB, UsedSpaceGB 

    Write-Host "===================Current Working VM: " + $currentVM.Name + "==================================="
    $totalUsed += $currentVM.UsedSpaceGB
    $totalProvisioned += $currentVM.ProvisionedSpaceGB



}



$totalUsed
$totalProvisioned

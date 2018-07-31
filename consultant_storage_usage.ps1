#Start-Transcript C:\Outputs\findSnapshots.log

Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
. 'C:\Admin Scripts\ESXi\functions\Get-VMFolderPath.ps1'
$VIServer="vcenter.cs.odu.edu"
#Connect-VIServer $VIServer -Credential (Import-clixml "C:\Admin Scripts\ESXi\vcenter_admin_creds.clixml")
Connect-VIServer $VIServer

$outputfile = "C:\Outputs\consultant_disk_usage.html"

If (Test-Path $outputfile) 
    { 
        Remove-Item $outputfile
    }
    
$VMs = Get-datastore | Where {$_.name -like '*CONSULTANT*'} | Get-VM | sort

$report = @()

 
Foreach ($VM in $VMs){
    #$line = Get-VM $VM | Select *

    $StorageFormat = $VM | Get-HardDisk | Select -ExpandProperty StorageFormat
    $line = “” | Select Name, vCPU, ‘Memory(GB)’, 'Used Space (GB)', 'Provisioned Space (GB)', 'Storage Format' ,Folder
    $line.Name = $VM.Name
    $line.vCPU = $vm.NumCPU
    $line.'Memory(GB)' = $VM.MemoryMB / 1024
    $line.'Used Space (GB)' = $VM.UsedSpaceGB
    $line.'Provisioned Space (GB)' = $VM.ProvisionedSpaceGB
    $line.'Storage Format' = $StorageFormat
    $line.'Folder' = $VM | Get-VMFolderPath
    $report += $line
}



$report | Sort-Object 'Used Space (GB)' -Descending | ConvertTo-Html -Head $Header -PreContent "<p><h2>Consultant Resource Usage Report</h2></p><br>" | Out-File C:\Outputs\consultant_disk_usage.html


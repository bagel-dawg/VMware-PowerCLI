Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

Get-VM | Get-View | %{ 
 $VMname = $_.Name 
 $_.guest.net | where {$_.MacAddress -eq "00:50:56:96:e5:84"} | %{
        $row = "" | Select VM, MAC
        $row.VM = $VMname 
        $row.MAC = $_.MacAddress 
        $report += $row 
  } 
  } 
$report



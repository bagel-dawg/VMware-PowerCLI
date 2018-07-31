Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
$VIServer="vcenter.cs.odu.edu"
Connect-VIServer $VIServer


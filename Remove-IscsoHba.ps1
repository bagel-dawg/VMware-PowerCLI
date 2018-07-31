Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
$HostCredentials = (Get-Credential -Username root -Message "Enter the root password for the ESXi Host.")

Connect-VIServer vcenter.cs.odu.edu

$servers = Get-VMHost

Disconnect-VIServer vcenter.cs.odu.edu

foreach($thisServer in $servers){

Connect-VIServer $thisServer -Credential $HostCredentials

Get-ISCSIHbaTarget -Address 192.168.51.50:3260 -Type Send | Remove-IScsiHbaTarget -Confirm:$false
Get-ISCSIHbaTarget -Address 192.168.51.51:3260 -Type Send | Remove-IScsiHbaTarget -Confirm:$false
Get-ISCSIHbaTarget -Address 192.168.51.52:3260 -Type Send | Remove-IScsiHbaTarget -Confirm:$false
Get-ISCSIHbaTarget -Address 192.168.51.53:3260 -Type Send | Remove-IScsiHbaTarget -Confirm:$false
Get-ISCSIHbaTarget -Address 192.168.51.54:3260 -Type Send | Remove-IScsiHbaTarget -Confirm:$false

Disconnect-VIServer $thisServer
}

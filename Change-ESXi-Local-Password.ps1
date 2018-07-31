Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$HostCredentials = (Get-Credential -Username root -Message "Enter the root password for the ESXi Host.")

$password_to_change = '#####'

$all_hosts = Get-VMHost | Select-Object -ExpandProperty Name

Disconnect-VIServer -Server vcenter.cs.odu.edu -Confirm:$false

foreach($esxi_host in $all_hosts){

    $esxi_host_name = $esxi_host #$esxi_host.Name

    #Create the nagios user and assign the readonly permission
    Connect-VIServer $esxi_host_name -Credential $HostCredentials
        Set-VMHostAccount -UserAccount nagios -Password $password_to_change -Confirm:$false
    Disconnect-VIServer -Server $esxi_host_name -Confirm:$false

}




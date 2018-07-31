Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$allHosts = Get-VMHost

Disconnect-VIServer -Server vcenter.cs.odu.edu -Confirm:$false

$HostCredentials = (Get-Credential -Username root -Message "Enter the root password for the ESXi Host.")

foreach($currentHost in $allHosts){

    Connect-VIServer $currentHost -Credential $HostCredentials
    New-VMHostAccount -Id nagios -Password '#######'
    New-VIPermission -Entity $currentHost -Principal nagios -Role ReadOnly -Propagate:$true
    Disconnect-VIServer -Server $currentHost -Confirm:$false

}



Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

$all_hosts = Get-VMHost

foreach($vmhost in $all_hosts){

    if($vmhost.Name -like "*dvx*"){continue;}


        Set-VMHostSysLogServer -VMHost $vmhost -SysLogServer tcp://172.18.8.118:1514

        #Restart the syslog service
        $esxcli = Get-EsxCli -VMHost $vmhost -V2
        $esxcli.system.syslog.reload.invoke()

        Get-VMHostFirewallException -Name "syslog" -VMHost $vmhost | set-VMHostFirewallException -Enabled:$true


}
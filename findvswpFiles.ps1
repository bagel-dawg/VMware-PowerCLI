$vCenter="vcenter.cs.odu.edu"
$datacenter="Computer Science"
Clear-Host
if (( Get-PSSnapin -name Vmware.Vimautomation.core -ErrorAction SilentlyContinue ) -eq $null ) {
 Add-PSSnapin vmware.vimautomation.core
 }
Connect-VIServer $vCenter
 
 $allds=dir -path vmstore:\$datacenter\ | select name
 #this should be all datastores
 $mastervmx= @()
 foreach ($myds in $allds){

    if( $myds.name -notlike "*.snapshot*" ){

        $myds2=$myds.name
        $vmfolders=dir -Path vmstore:\$datacenter\$myds2| select name
 
        foreach ($vmfolder in $vmfolders){

    if( ( $vmfolder.name -notlike ".*" ) -and ( $vmfolder.Name -notlike "*q_01*" ) ){

        $vmfolder2=$vmfolder.name
        $vmxs=dir -Path vmstore:\$datacenter\$myds2\$vmfolder2 | select name,datastorefullpath,lastwritetime | Where-Object {$_.name -like "vmx*vswp"}
    
        if ($vmxs.count -gt 1){
            foreach ($vmx in $vmxs){
                $mastervmx+=$vmx
            }
        }
 }
 }
    }
}
 $mastervmx|Export-Csv -NoTypeInformation -UseCulture -Path C:\outputs\$vcenter-vmxinfo.csv
Disconnect-viserver -confirm:$falsec

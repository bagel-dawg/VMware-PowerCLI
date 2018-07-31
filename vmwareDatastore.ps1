
param (
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]$vmhosts = $(throw "vmhosts must be specified")
)
 
$masterList = @{}
 
# Use the first host as the reference host
foreach ($datastore in Get-Datastore -VMHost $vmhosts[0]) {
    $masterList[$datastore.Name] = "Missing"
}
 
# Check all of the hosts against the master list
foreach ($vmhost in $vmhosts) {
    $testList = @{} + $masterList
 
    foreach ($datastore in Get-Datastore -VMHost $vmhost) {
        $dsName = $datastore.Name
 
        # If we have a match change the status
        if ($testList.ContainsKey($dsName)) {
            $testList[$dsName] = "OK"
        }
        # Otherwise we have found a datastore that wasn't on our reference host.
        else {
            $testList[$dsName] = "Extra"
        }
    }
 
    # Output our findings
    foreach ($dsName in $testList.Keys) {
        $info = "" | Select-Object VMHost, Datastore, Status
        $info.VMHost = $vmhost.Name
        $info.Datastore = $dsName
        $info.Status = $testList[$dsName]
        $info
    }
}
<#
.SYNOPSIS
Check a set of hosts to see if they see the same datastores.  This script
does not filter local datastores.
 
.PARAMETER clusters
An array of the hosts you want to check.
 
.EXAMPLE
.\Validate-Datatores.ps1 (Get-Cluster cluster1 | Get-VMHost)
#>
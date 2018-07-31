Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer vcenter.cs.odu.edu

Import-Module 'C:\Admin Scripts\functions\EnhancedHTML2.psm1'

$output_path = "C:\temp\vm_resources.html"

$head_script = '

                <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.16/css/jquery.dataTables.min.css" />

               '

$post_script = '
                <script>
                $(document).ready(function() {
                    $(''#example'').DataTable();
                 } );
                </script>

                '


if(Test-Path $output_path) { Remove-Item $output_path }

$All_vms = Get-VM | Select Name, @{N="disktype";E={(Get-Harddisk $_).Storageformat}}, UsedSpaceGB, ProvisionedSpaceGB, numCPU, MemoryMB

$html_frag = $All_vms | ConvertTo-EnhancedHTMLFragment -As Table -TableCssID "example" -TableCssClass "display" -Properties Name, UsedSpaceGB, ProvisionedSpaceGB, numCPU, MemoryMB  | out-string

$html = ConvertTo-EnhancedHTML  -HTMLFragments $html_frag -jQueryURI "https://code.jquery.com/jquery-1.12.4.js" -jQueryDataTableURI "https://cdn.datatables.net/1.10.16/js/jquery.dataTables.min.js" -CssUri "https://cdn.datatables.net/1.10.16/css/jquery.dataTables.min.css"
$html | Out-File $output_path

Disconnect-VIServer -Confirm:$false

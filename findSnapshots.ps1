#Start-Transcript C:\Outputs\findSnapshots.log

Get-Module -ListAvailable VMware* | Import-Module
#Add-PSSnapin VMware.VimAutomation.Core
$VIServer="vcenter.cs.odu.edu"
Connect-VIServer $VIServer -Credential (Import-clixml "C:\Admin Scripts\ESXi\vcenter_admin_creds.clixml")

$outputfile = "C:\Outputs\snapshots.html"

If (Test-Path $outputfile) 
    { 
        Remove-Item $outputfile
    }
    
 
$isEmpty = Get-VM | Get-Snapshot | Where { $_.Created -lt (Get-Date).AddDays(-3)}
$Report = Get-VM | Get-Snapshot | Where { $_.Created -lt (Get-Date).AddDays(-3)} | Select VM,Name,Description,Size,Created | Sort-Object -Property VM | ConvertTo-Html -Head $Header -PreContent "<p><h2>Snapshot Report - These snapshots have been deleted</h2></p><br>"

Get-VM | Where-Object {$_.Name -notlike '*Atria*'} | Get-Snapshot | Where { $_.Created -lt (Get-Date).AddDays(-3)} | Remove-Snapshot -Confirm:$false



  $user = "justus@cs.odu.edu"
  $smtpServer = "relay.cs.odu.edu" 
  $smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
  $msg = New-Object Net.Mail.MailMessage 
  $msg.To.Add($user) 
        $msg.From = "vmware@cs.odu.edu" 
  $msg.Subject = "Deleted VMWare Snapshot Report" 
        $msg.IsBodyHTML = $true 
        $msg.Body = $Report


IF([string]::IsNullOrEmpty($isEmpty)) {            
    $body = ""  
    Write-Host "Body empty...not sending email....."     
} else {        
    Write-Host "Body contains data, sending email..."    
    $smtp.Send($msg)  
    $body = ""          
}


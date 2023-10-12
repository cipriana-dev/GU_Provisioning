# Final imaging receipt

# Gather all of the info then format as HTML output.

function chkApps ($appName) {
  $objApp = Get-WmiObject -Class Win32_Product | where name -like $appName* | select Name, Version
  $strName = $objApp.Name
  $strVer = $objApp.Version
  if ($strName -Match $appName) {
    write-output "`t $strName $strVer exists." | Out-File -FilePath $txtFile -Append
  }else{
    write-output "`t $appName does not exist." | Out-File -FilePath $txtFile -Append
  }
}

$txtFile = "c:\GU\Receipt.txt"

# Computer Name
$compName = $env:computername
write-output  "Imaging report for $compName" `n| Out-File -FilePath $txtFile 

# GU Folders
$Folder = 'C:\GU'
if (Test-Path -Path $Folder) {
   write-output  "Folder C:\GU exists `n" | Out-File -FilePath $txtFile -Append
} else {
   write-output "Folder C:\GU doesn't exist.`n" | Out-File -FilePath $txtFile -Append
}

# CIS Policies

# Image Versions
$imageVer = Get-Content "C:\GU\imagever.txt"
write-output  "Image version (file): $imageVer" | Out-File -FilePath $txtFile -Append
$imageReg = (Get-ItemProperty -Path HKLM:\Software\Georgetown -Name Version).Version
write-output  "Image version (registry): $imageReg `n" | Out-File -FilePath $txtFile -Append

# Applications
write-output  "Core application installations: " | Out-File -FilePath $txtFile -Append 
# CrowdStrike installed
chkApps ("CrowdStrike Sensor Platform")

# Tenable Installed
chkApps ("Tenable")

# AnyConnect installed
chkApps ("Cisco AnyConnect Secure Mobility Client")

# AnyConnect pre-GINA
chkApps ("Cisco AnyConnect Start Before Login Module")

# BGInfo

# Chrome 
chkApps ("Google Chrome")

# Managed Chrome

# Office
chkApps ("Microsoft Office Professional Plus 2019 - en-us")

# SCCM
chkApps ("Configuration Manager Client")

# Umbrella
chkApps ("Umbrella Roaming Client")


# Bitlocker - Need to address the admin permission issue
$BLinfo = Get-Bitlockervolume

if($blinfo.ProtectionStatus -eq 'On' -and $blinfo.EncryptionPercentage -eq '100'){
    write-output "'$env:computername - '$($blinfo.MountPoint)' is encrypted"| Out-File -FilePath $txtFile -Append
}else {
    write-output "`nThe drive is not encrypted"| Out-File -FilePath $txtFile -Append
}

# Bitlocker key exported
Get-ADComputer -Identity "uis-wl-1rm4m13" -Properties *

# Time Zone
$strTZ = Get-TimeZone
Write-Output "Time Zone is set to $strTZ"| Out-File -FilePath $txtFile -Append

# Domain Joined
if ((gwmi win32_computersystem).partofdomain -eq $true) {
    write-output "Joined to the domain."| Out-File -FilePath $txtFile -Append 
} else {
    write-host "Not joined to the domain." | Out-File -FilePath $txtFile -Append
}
# Administrator Enabled
$stradmin = Get-LocalUser -Name "administrator"
if($stradmin.Enabled -eq "true"){
  write-output "Local administrator account is enabled." | Out-File -FilePath $txtFile -Append
}else{
  write-output "Local administrator account is not enabled." | Out-File -FilePath $txtFile -Append
}

# Tssstaff account created

# Local administrators list
Get-LocalGroupMember -Group "Administrators"
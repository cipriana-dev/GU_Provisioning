# Set AutoLogin
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUsername = "PATXUser"
$DefaultPassword = "InServiceTo"
# Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
#Set-ItemProperty $RegPath "DefaultUsername" -Value "$DefaultUsername" -type String 
#Set-ItemProperty $RegPath "DefaultPassword" -Value "$DefaultPassword" -type Strin
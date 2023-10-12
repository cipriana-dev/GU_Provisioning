
Function WriteLog
{
    # Log file - add write-host functionality as well?
    # $LogFile specified in main script
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}

# Add Tanium markers
function TanRun {
    param (
        [string]$TanApp,
        [string]$TanResult
    )
    
$RegistryPath = 'HKLM:\SOFTWARE\Georgetown\Tanium'
# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $TanApp -Value $TanResult -PropertyType String -Force 
}

# Check and create registry key
function setRegKey {
    param (
        [string]$regKeyPath
    )
    If (-NOT (Test-Path $regKeyPath)) 
    {
        WriteLog "$regKeyPath does not exist. Creating..."
        try {
            New-Item -Path $regKeyPath -Force | Out-Null
            WriteLog "$regKeyPath created."
        }
        catch {WriteLog "$regKeyPath creation failed."} 
        else {
        WriteLog "$regKeyPath already exists."
    }   
    }
}  

function setRegValue {
param (
        [string]$regKeyPath,
        [string]$regVal,
        [string]$regData,
        [string]$regType
    )  
    $regValExists = Get-ItemPropertyValue $regKeyPath -Name $regVal
    if ($regValExists){
        WriteLog "$regVal already exists. Updating value."
        Set-ItemProperty -Path $regKeyPath -Name $regVal -Value $regData -Force
        }
        else 
        {
            New-ItemProperty -Path $regKeyPath -Name $regVal -Value $regData -PropertyType $regType -Force 
            WriteLog "$regVal created."
        }
}

function addFolder {
    param (
        [string]$foldPath
    )
    if (-not (Test-Path $foldPath)) {
        
        WriteLog "$foldPath does not exist. Creating..."
        try {
            New-Item -Path $foldPath -ItemType Directory
            WriteLog "$foldPath created."
        }
        catch {
            WriteLog "Creation of $foldPath failed."
        }
    }
    else {
      WriteLog "$foldPath already exists."  
    }
}

#run process and get exit code
function runApp {
    param (
        [string]$appPath,
        [string]$strArgs  
    )
    WriteLog "Starting $appPath..."
    try {
        $run = (Start-Process -FilePath $appPath -ArgumentList $strArgs -PassThru -Wait)
    }
    catch {
        WriteLog "Exeution of $appPath could not start."
    }
    $exCode = $run.ExitCode.ToString()
    WriteLog "$appPath returned an exit code of $exCode"
    return $exCode
}
function createShortcut {
    param (
        [string]$scutTitle,
        [string]$scutPath,
        [string]$scutCommand,
        [string]$scutArgs
    )
    try {
        WriteLog "Adding shortcut for $scutTitle to $scutPath." 
        $WscriptObj = New-Object -ComObject ("WScript.Shell")
        $shortcut = $WscriptObj.CreateShortcut("$scutPath\$scutTitle.lnk")
        $shortcut.TargetPath = $scutPath
        $Shortcut.Arguments = $scutArgs
        $shortcut.Save() 
        WriteLog "Successfully created the shortcut."
    }
    catch {
        WriteLog "Shortcut creation failed."
    }
}
  function fileDownload {
        param (
            [string]$srcURI,
            [string]$dlPath
        )
        try {
            WriteLog "Downloading $srcURI..."
            (New-Object Net.WebClient).DownloadFile($srcURI, $dlPath)
            WriteLog "Download complete."
        }
        catch {
            WriteLog "Download failed."
        }
    }

function addCustomTag {
    param (
        [string]$customTag
    )
    $now = Get-Date -Format "MM/dd/yyyy hh:mm:ss tt"
    $regKeyPath = 'HKLM:\SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Tags'
    If (-NOT (Test-Path $regKeyPath)) 
    {
        WriteLog "$regKeyPath does not exist. Creating..."
        try {
            New-Item -Path $regKeyPath -Force | Out-Null
            WriteLog "$regKeyPath created."
        }
        catch {WriteLog "$regKeyPath creation failed."} 
        else 
    {
        WriteLog "$regKeyPath already exists."
    }  
    }
    setRegValue -regKeyPath $regKeyPath -regVal $customTag -regData "Added: $now" -regType String 
     
}

function WGInstall {

Param
  (
    [parameter(Mandatory=$false)]
    [String] $ProgramName
  )

# resolve winget_exe
$winget_exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
if ($winget_exe.count -gt 1){
        $winget_exe = $winget_exe[-1].Path
}

if (!$winget_exe){Write-Error "Winget not installed"}

& $winget_exe install --exact --id $ProgramName --silent --accept-package-agreements --accept-source-agreements --scope=machine $param --Force  | Out-Default
}

function addGULabel {
    param (
        [string]$GULabel
    )
    $now = Get-Date -Format "MM/dd/yyyy hh:mm:ss tt"
    $regKeyPath = 'HKLM:\SOFTWARE\Georgetown\Labels'
    If (-NOT (Test-Path $regKeyPath)) 
    {
        WriteLog "$regKeyPath does not exist. Creating..."
        try {
            New-Item -Path $regKeyPath -Force | Out-Null
            WriteLog "$regKeyPath created."
        }
        catch {WriteLog "$regKeyPath creation failed."} 
        else {
        WriteLog "$regKeyPath already exists."
    }  
    }
    setRegValue -regKeyPath $regKeyPath -regVal $GULabel -regData $now -regType String 
     
}

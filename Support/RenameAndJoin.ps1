<# 
.NAME
    Computer naming
#>

[Reflection.Assembly]::LoadFile("C:\GU\sqlite\System.Data.SQLite.dll")

# region DeclareFunctions
Function Get-ScreenRes {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class PInvoke {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
}
"@
$hdc = [PInvoke]::GetDC([IntPtr]::Zero)
$scrResX = [PInvoke]::GetDeviceCaps($hdc, 118) # width
$scrResY = [PInvoke]::GetDeviceCaps($hdc, 117) # height
$startPosX = ($scrResX / 2) - 600
return $startPosX
#return $startPosY
}

Function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}

Function Get-SerialNumber
{
# Get the serial number. Note: Lenovo now uses Win32_BIOS instead of Win32_Product (older machines may not work).
WriteLog "Getting the serial number."
$strSN = (Get-CimInstance Win32_BIOS).SerialNumber
WriteLog "Raw Serial Number is:  $strSN"
#Is it too long?
if ($strSN.Length -gt 8) {
    WriteLog "Serial number is too long."
    $snNumDiff = $strSN.Length - 8
    #write-host $snNumDiff
    $strSN = $strSN.substring($snNumDiff) 
    $arrComputer[0]  = $strSN
    WriteLog "Adjusted SN is: " $arrComputer[0]
}
else {
    WriteLog "Serial number is within character limits."
    $arrComputer[0] = $strSN
    WriteLog "New Array SN is: " $arrComputer[0]
    #$arrComputer
    }   
}

Function get-CompType {
    $chassisType = (Get-CimInstance Win32_SystemEnclosure).ChassisTypes
    WriteLog "Computer chassis type is: $chassisType"
    switch ($chassisType)
    {
        1{$WDWL = $desktop}
        2{$WDWL = $desktop}
        3{$WDWL = $desktop}
        4{$WDWL = $desktop}
        5{$WDWL = $desktop}
        6{$WDWL = $desktop}
        7{$WDWL = $desktop}
        8{$WDWL = $desktop}
        9{$WDWL = $laptop}
        10{$WDWL = $laptop}
        11{$WDWL = $laptop}
        12{$WDWL = $laptop}
        13{$WDWL = $laptop}
        14{$WDWL = $laptop}
        15{$WDWL = $laptop}
        16{$WDWL = $laptop}
        30{$WDWL = $laptop}
        31{$WDWL = $laptop}
        32{$WDWL = $laptop}
    }
    $arrComputer[2] = $WDWL
    WriteLog "Computer type is"
    WriteLog $arrComputer[2]
}
Function Format-CompName {
# Build the computer name
   
 WriteLog "Prefix is: " 
 writelog $arrComputer[1]
 WriteLog "Middle name is: "
 WriteLog $arrComputer[2]
 Get-SerialNumber
 WriteLog "SN is:"
 WriteLog $arrComputer[0]
 $strCompName = $arrComputer[1] + $arrComputer[2] + $arrComputer[0]
 WriteLog "Device name before Return: $strCompName"
 #$strCompName
}  

Function Get-Dept-Selection
{
$sDatabasePath="C:\GU\ou.db"
$sDatabaseConnectionString=[string]::Format("data source={0}",$sDatabasePath)
$oSQLiteDBConnection = New-Object System.Data.SQLite.SQLiteConnection
$oSQLiteDBConnection.ConnectionString = $sDatabaseConnectionString
$oSQLiteDBConnection.open()
$oSQLiteDBCommand=$oSQLiteDBConnection.CreateCommand()
$theDept = $GroupList.SelectedItem
writelog $GroupList.SelectedItem
writelog "SELECT ou, prefix from OUs WHERE department_name = $theDept"
$oSQLiteDBCommand.Commandtext="SELECT ou, prefix from OUs WHERE department_name = '$theDept'"
$oSQLiteDBCommand.CommandType = [System.Data.CommandType]::Text
$oDBReader=$oSQLiteDBCommand.ExecuteReader()
$oDBReader.GetValues()
while($oDBReader.HasRows) 
{
if($oDBReader.Read())
{
    $value = "" | Select-Object -Property prefix,ou
    # Write-Host $oDBReader["ou"]
    $arrComputer[1] = $oDBReader["prefix"] 
    $arrComputer[4] = $oDBReader["ou"]
    # Write-Host $arrComputer[4]
}
}
$oDBReader.Close()
# $objComputer.strPrefix = $value.prefix
# objComputer.strOU = $value.ou
# $ouret = [PSCustomObject]@{
  #  ou = $ou
  #
  #  prefix = $prefix
}
WriteLog $arrComputer[4]
# return $ouret
#Write-Host $ou
#return $strTest

Function Get-Departments
{
    
    # $DeptIndex = 0
    $sDatabasePath="C:\GU\ou.db"
    $sDatabaseConnectionString=[string]::Format("data source={0}",$sDatabasePath)
    $oSQLiteDBConnection = New-Object System.Data.SQLite.SQLiteConnection
    $oSQLiteDBConnection.ConnectionString = $sDatabaseConnectionString
    write-host $sDatabaseConnectionString
    $oSQLiteDBConnection.open()
    $oSQLiteDBCommand=$oSQLiteDBConnection.CreateCommand()
    $oSQLiteDBCommand.Commandtext="SELECT * from OUs" # | Where-Object { $_department}
    $oSQLiteDBCommand.CommandType = [System.Data.CommandType]::Text
    $oDBReader=$oSQLiteDBCommand.ExecuteReader()
    $oDBReader.GetValues()
    while($oDBReader.HasRows) 
    {
        if($oDBReader.Read())
        {
        $GroupList.Items.Add($oDBReader["department_name"] )
        #$DeptIndex = $DeptIndex + 1    
        }
    #$ComputerNaming.Controls.Add($DepartmentGroup)
    } 
    
    $oDBReader.Close()

}

Function Build-DevName
{}
# endregion

Function choose_dept
{
    Get-Dept-Selection
    get-CompType
    $compNameTxt.Text = $arrComputer[1] + $arrComputer[2] + $arrComputer[0]
    #$compNameTxt.Text = "$($strTest2.prefix)"
    #$compNameTxt.Text = $strTest
    #Write-Host $strTest2
    #$strTest2.
    
}

Function rename_computer
{
$regPath = "HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName"
$regPath2 = "HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName"
Set-ItemProperty -Path $RegPath -Name "ComputerName" -Value $strNameText -Force
Set-ItemProperty -Path $RegPath2 -Name "ComputerName" -Value $strNameText -Force
$renResult = Rename-Computer -NewName $strNameText
$StatusBox.Text = $StatusBox.Text + "`r`n'$renResult'"
}

# Start of main script

# Create log file
$Logfile = "C:\GU\Logs\$env:computername.log"
Add-content $LogFile -value "Naming script is starting"

 # Set initial variables
          $objComputer = [PSCustomObject]@{
           strOU = "ou=Unassigned,ou=New"
            strPrefix = "GU"
            strType = "-WD-"
           strSN = "SERIAL"
           strDept = "Unassigned"
    }
    $desktop = "-WD-"
    $laptop = "-WL-"

# Instead of using an object, using an array (much simpler)
$arrComputer = New-Object -TypeName "System.Collections.ArrayList"
$arrComputer = [System.Collections.ArrayList]@()
$arrComputer.Add('SERIAL')
$arrComputer.Add('GU')
$arrComputer.Add('-WD-')
$arrComputer.add('Unassigned')
$arrComputer.add('ou=Unassigned,ou=New')
WriteLog "Default serial number is:"$arrComputer[0]
# $testSN = "SERIAL"
 # Build the initial device name to populate the form
 Format-CompName
 WriteLog "Function return ArrSN: " 
 WriteLog $arrComputer[0]

Add-Type -AssemblyName System.Windows.Forms

[System.Windows.Forms.Application]::EnableVisualStyles()

[Reflection.Assembly]::LoadFile("C:\GU\System.Data.SQLite.dll")

#region CreateForm
$ComputerNaming                  = New-Object system.Windows.Forms.Form
$ComputerNaming.StartPosition    = 'Manual'
$ComputerNaming.AutoSize         = $true
$ComputerNaming.ClientSize       = New-Object System.Drawing.Point(1200,700)
$ComputerNaming.text             = "Computer Name and Departmen Selection v.2"
$ComputerNaming.TopMost          = $false
$ComputerNaming.BackColor        = [System.Drawing.ColorTranslator]::FromHtml("#012169")#012169
$ComputerNaming.Location         = New-Object System.Drawing.Point(100,100)
#endregion

#region CreateBanner
$bannerLbl                       = New-Object system.Windows.Forms.Label
$bannerLbl.text                  = "Computer Naming"
$bannerLbl.AutoSize              = $false
$bannerLbl.width                 = 1200
$bannerLbl.height                = 40
#$bannerLbl.Anchor                = ''
$bannerLbl.location              = New-Object System.Drawing.Point(0,0)
$bannerLbl.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',24,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$bannerLbl.ForeColor             = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")
$bannerLbl.BackColor             = [System.Drawing.ColorTranslator]::FromHtml("#041E42")
$bannerLbl.TextAlign             = "MiddleCenter"
#endregion

#region AddSeal
$GUseal                          =  [System.Drawing.Image]::Fromfile('C:\GU\seal.jpg')
$GUpictureBox = new-object Windows.Forms.PictureBox
$GUpictureBox.Width =  212
$GUpictureBox.Height =  207
$GUpictureBox.Location = New-Object Drawing.Point 910,75
$GUpictureBox.Image = $GUseal
#endregion

#region CreateComputerNameLBL
$compNameLbl                     = New-Object system.Windows.Forms.Label
$compNameLbl.text                = "Computer Name:"
$compNameLbl.AutoSize            = $true
$compNameLbl.width               = 25
$compNameLbl.height              = 10
$compNameLbl.location            = New-Object System.Drawing.Point(30,80)
$compNameLbl.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',14,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$compNameLbl.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

$compNameTxt                     = New-Object system.Windows.Forms.TextBox
$compNameTxt.multiline           = $false
$compNameTxt.text                = $arrComputer[1] + $arrComputer[2] + $arrComputer[0]
$compNameTxt.width               = 190
$compNameTxt.height              = 20
$compNameTxt.enabled             = $true
$compNameTxt.ReadOnly            = $true
$compNameTxt.location            = New-Object System.Drawing.Point(220,80)
$compNameTxt.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',14) #, [System.Drawing.FontStyle]::Bold)
# $compNameTxt.Padding             = 10
# n$compNameTxt.ForeColor           = "Blue"
#$compNameTxt.BackColor           = "DarkSlateGray"
#endregion

#region CreateRadioButtonGroup
$CompTypeGroup                   = New-Object system.Windows.Forms.Groupbox
$CompTypeGroup.height            = 80
$CompTypeGroup.width             = 800
$CompTypeGroup.text              = "Computer Type"
#$CompTypeGroup.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',14)
$CompTypeGroup.Font              = [System.Drawing.Font]::new("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
$CompTypeGroup.location          = New-Object System.Drawing.Point(30,130)
$compTypeGroup.ForeColor       = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

$compTypeRad1                    = New-Object system.Windows.Forms.RadioButton
$compTypeRad1.text               = "Laptop"
$compTypeRad1.AutoSize           = $true
$compTypeRad1.width              = 100
$compTypeRad1.height             = 20
$compTypeRad1.location           = New-Object System.Drawing.Point(80,35)
$compTypeRad1.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$compTypeRad2                    = New-Object system.Windows.Forms.RadioButton
$compTypeRad2.text               = "Desktop"
$compTypeRad2.AutoSize           = $true
$compTypeRad2.width              = 100
$compTypeRad2.height             = 20
$compTypeRad2.location           = New-Object System.Drawing.Point(300,35)
$compTypeRad2.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$compTypeRad3                    = New-Object system.Windows.Forms.RadioButton
$compTypeRad3.text               = "VM"
$compTypeRad3.AutoSize           = $true
$compTypeRad3.width              = 100
$compTypeRad3.height             = 20
$compTypeRad3.location           = New-Object System.Drawing.Point(520,35)
$compTypeRad3.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
#endregion

#region CreateDepartmentList
$DepartmentGroup                 = New-Object system.Windows.Forms.Groupbox
$DepartmentGroup.height          = 460
$DepartmentGroup.width           = 800
$DepartmentGroup.text            = "Department"
$DepartmentGroup.location        = New-Object System.Drawing.Point(30,140)
$DepartmentGroup.Font              = [System.Drawing.Font]::new("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
$DepartmentGroup.ForeColor        = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

$GroupList                       = New-Object System.Windows.Forms.ListBox
$GroupList.text                  = "ListView"
$GroupList.width                 = 780
$Grouplist.height                = 450
$GroupList.location              = New-Object System.Drawing.Point(10,27)
$GroupList.Font                  = [System.Drawing.Font]::new("Microsoft Sans Serif", 12)
Get-Departments
$GroupList.SelectedIndex = 0
$GroupList.TabIndex = 0
 #endregion

#region SelectButton
$BuildBtn                        = New-Object System.Windows.Forms.Button
$BuildBtn.Text                   = "Build Computer Name"
$BuildBtn.location               = New-Object System.Drawing.Point(900,350)
$BuildBtn.Width                  = 250
$BuildBtn.Height                 = 50
$BuildBtn.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("#000000")
$BuildBtn.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("#BBBCBC")   
$BuildBtn.Font                   = [System.Drawing.Font]::new("Microsoft Sans Serif", 12)
$BuildBtn.FlatStyle              = [System.Windows.Forms.FlatStyle]::Flat
$BuildBtn.Cursor                 = "Hand"
$BuildBtn.Margin                 = "0,5,15,0"
$BuildBtn.Padding                = 10

#endregion

#region BottomBanner
$bottomLbl                       = New-Object system.Windows.Forms.Label
$bottomLbl.AutoSize              = $true
$bottomLbl.width                 = 900
$bottomLbl.height                = 20
$bottomLbl.location              = New-Object System.Drawing.Point(25,507)
$bottomLbl.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$bottomLbl.BackColor             = [System.Drawing.ColorTranslator]::FromHtml("#041E42")

#endregion

#region StatusBox
$StatusBox                = New-Object System.Windows.Forms.TextBox
$StatusBox.height          = 460
$StatusBox.width           = 800
$StatusBox.text            = "Rename and Domain Join Status"
$StatusBox.location        = New-Object System.Drawing.Point(30,140)
#$StatusBox.Font              = [System.Drawing.Font]::new("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
#$StatusBox.ForeColor        = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")
$StatusBox.Multiline        = $true

#endregion
$GroupList.add_SelectedIndexChanged({
    choose_dept
    #Write-Host "Selecting different department..."
})

$ComputerNaming.controls.AddRange(@($bannerLbl,$compNameLbl,$compNameTxt,$DepartmentGroup,$bottomLbl, $BuildBtn,$GUpictureBox)) #$CompTypeGroup,
#$CompTypeGroup.controls.AddRange(@($compTypeRad1,$compTypeRad2,$compTypeRad3))
$DepartmentGroup.controls.AddRange(@($GroupList))

#region Logic 

# This didn't warrant it's own script so it's here
set-timezone -name "Eastern Standard Time"

$BuildBtn.Add_Click({
    Get-Dept-Selection
    get-CompType
    $strNameText = $arrComputer[1] + $arrComputer[2] + $arrComputer[0]
    if ($arrComputer[2] = "-WL-") {
        $ouPrefix = "ou=Laptop,"
    }
    else {
        $ouPrefix = "ou=Desktop,"
    }
    $strMsgText = "You have selected:`nComputer Name: $strNameText `nOU to Join: " + $ouPrefix + $arrComputer[4] + ",Ou=Orgs,dc=georgetown,dc=mei,dc=georgetown,dc=edu" + "`nAre you sure you want to continue?"
    $objMsg = [System.Windows.Forms.MessageBox]::Show($strMsgText, 'Selected Items','YesNo')
    $DepartmentGroup.Visible = $false
    $ComputerNaming.Controls.Add($StatusBox)
    $StatusBox.Visible = $true
    $StatusBox.Text = $StatusBox.Text + "`r`nHi there!"
    #$StatusBox.AppendText("`r`nTesting!!!")
    switch ($objMsg) {
        "Yes" {
            $StatusBox.AppendText("`r`nYou pressed OK.`r`nThe computer will be renamed to $strNameText")
            #rename_computer
            $ouPath = $arrComputer[4] + ",Ou=Orgs,dc=georgetown,dc=mei,dc=georgetown,dc=edu"
            #$objCreds = Get-Credential -Message "Please enter your user name and password."
            $objCreds = $host.ui.PromptForCredential("User Authentication" , "Please enter your NetID and password.", "", "GEORGETOWN")
            $pw = $objCreds.Password | ConvertFrom-SecureString
            $StatusBox.AppendText("`r`nNetID is " + $objCreds.UserName + " with password " + $objCreds.$pw)
            $strJoin = Add-Computer -credential $objCreds -DomainName "georgetown.mei.georgetown.edu" -OUPath $ouPath -NewName $strNameText -PassThru -Verbose *>&1
            $statusbox.AppendText("`r`n" + $strJoin)
            $statusbox.AppendText("`r`nAdding GEORGETOWN\TSS Staff to the local admin group...")
            $strAddGP = Add-LocalGroupMember -Group Administrators -Member "GEORGETOWN\TSS Staff" -Verbose *>&1
            $statusbox.AppendText("`r`n" + $strAddGP)
            }
        "No" {
            $StatusBox.AppendText( "You pressed Cancel.")
        }
    }
    })
#endregion

[void]$ComputerNaming.ShowDialog()

#$vals =Get-Dept-Selection
#write-host "Prefix: $( $vals.prefix)"
#write-host "OU: $( $vals.ou)"
# $GroupList.SelectedIndexChanged  = [System.Windows.Forms.MessageBox]::Show($GroupList.SelectedItem)

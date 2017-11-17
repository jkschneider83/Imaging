<#
 This sysprep is for Any AF Image. This script will Activate Microsoft office 2016, 
 Install the Staff Kaseya and Add machine to the Win 7 OU in Active Directory.
#>

netsh wlan add profile filename="afwifi.xml" user=all

Start-sleep -s 30

$username = "AF\K2agentadmin"
$password = ConvertTo-SecureString "k2@g3nt4d1n" -AsPlainText -Force
$myCred = New-Object System.Management.Automation.PSCredential ($username,$password)
$path = "\\af-windeploy\SSMFS$"
$source = "P:"
$drive = "P"
$DOScmd = "\\af-windeploy\SSMFS$\SSM.exe \\af-windeploy\SSMFS$ /accept /noreboot"
New-PSDrive -Name $drive -PSProvider FileSystem -Root $path  -Persist -Credential $myCred
CMD.EXE /C $DOScmd
remove-psdrive -name $drive

<# activate win7 #>
$computer = gc env:computername
$key = "YPV4G-FHF8M-FFW2P-M2JGV-X6QTX"
$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer
$service.InstallProductKey($key)
$service.RefreshLicenseStatus()

Start-sleep -s 10

<# activate office 2013
Set-Location "C:\Program Files\Microsoft Office\Office15"
cscript ospp.vbs /inpkey:Y4XNJ-GXXWV-77MJC-4VB98-YPXKV
cscript ospp.vbs /act #>

<# activate office 2016 #>
Set-Location "C:\Program Files\Microsoft Office\Office16"
cscript ospp.vbs /inpkey:MNX9H-9JY2V-JQ29H-KY3DP-P9XYB
cscript ospp.vbs /act

Start-sleep -s 10

<# copying file from networkshare #>

$dir = "c:\sysprep"
$username = "AF\script"
$password = ConvertTo-SecureString “script” -AsPlainText -Force
$myCred = New-Object System.Management.Automation.PSCredential $username, $password
$path = "\\edk8-nas\fileshares\imageDeployment"
$source = "f:"
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password
$drive = "F"

New-PSDrive -Name $drive -PSProvider FileSystem -Root $path  -Persist -Credential $Cred


#check for drive mapping.
If (Test-Path $source) 
{
    Write-host **Installing Kaseya***
    copy-item -Path $source\kaseya\KcsSetup.exe -Destination C:\sysprep\kaseya
    
     <# kaseya install code #>

    Set-Location "C:\sysprep\kaseya"
    $AllArgs = '/qb'
    & .\KcsSetup.exe $AllArgs
  
   Start-sleep -s 15
  
   Write-host **Kaseya installed successfully***

    remove-psdrive -name $drive
}
Else
{
    Write-Host *********************CANNOT LOCATE PATH: $source ************************
    write-host *********************Instalation failed. ********************************
    pause
}

Start-sleep -s 10

#Add machine to ActiveDirectory

Add-Computer -DomainName af.org -OUPath "OU=Win7 Computers,OU=AF,DC=af,DC=org" -Credential $mycred -ErrorAction Inquire -PassThru

Remove-Item $dir\* -recurse
Write-host ***************************Rebooting***************************

Start-sleep -s 10

Restart-Computer -ComputerName localhost

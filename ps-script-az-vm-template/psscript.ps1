 
#Function1 - Disable Enhanced Security for Internet Explorer
Function Disable-InternetExplorerESC
{
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force -ErrorAction SilentlyContinue -Verbose
    #Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green -Verbose
}

#Function2 - Enable File Download on Windows Server Internet Explorer
Function Enable-IEFileDownload
{
    $HKLM = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    $HKCU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    Set-ItemProperty -Path $HKLM -Name "1803" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKCU -Name "1803" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKLM -Name "1604" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKCU -Name "1604" -Value 0 -ErrorAction SilentlyContinue -Verbose
}

#Function3 - Enable Copy Page Content in IE
Function Enable-CopyPageContent-In-InternetExplorer
{
    $HKLM = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    $HKCU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    Set-ItemProperty -Path $HKLM -Name "1407" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKCU -Name "1407" -Value 0 -ErrorAction SilentlyContinue -Verbose
}

#Function4 Install Chocolatey
Function InstallChocolatey
{   
    #[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
    #[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
    $env:chocolateyUseWindowsCompression = 'true'
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -Verbose
    choco feature enable -n allowGlobalConfirmation
}

#Function5 Disable PopUp for network configuration

Function DisableServerMgrNetworkPopup
{
    cd HKLM:\
    New-Item -Path HKLM:\System\CurrentControlSet\Control\Network -Name NewNetworkWindowOff -Force 

    Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
}

Function CreateLabFilesDirectory
{
    New-Item -ItemType directory -Path C:\LabFiles -force
}

Function DisableWindowsFirewall
{
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

}

Function Show-File-Extension
{
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty $key HideFileExt 0
    Stop-Process -processname explorer
}



#Function - InstallPowerBIDesktop
Function InstallPowerBiDesktopChoco
{
    choco install powerbi -y -force

}
Function InstallPowerBIDesktop
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe","C:\Packages\PBIDesktop_x64.exe")
    Start-Process -FilePath "C:\Packages\PBIDesktop_x64.exe" -ArgumentList '-quiet','ACCEPT_EULA=1'
}


Function InstallScreenConnectforSPL
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/software/screenconnectspl.msi","C:\Packages\screenconnectspl.msi")
    Start-Process msiexec.exe -Wait '/I C:\Packages\screenconnectspl.msi /qn' -Verbose
}

Function InstallCloudLabsShadow($odlid, $InstallCloudLabsShadow)
{
    if($InstallCloudLabsShadow -eq 'yes')
    {
        $WebClient = New-Object System.Net.WebClient
        $url1 = "https://spektrasystems.screenconnect.com/Bin/ConnectWiseControl.ClientSetup.msi?h=instance-ma1weu-relay.screenconnect.com&p=443&k=BgIAAACkAABSU0ExAAgAAAEAAQDhrCYwK%2BhPzyOyTYW71BahP4Q7hsWvkU20udO6d7cGuH8VAADzVNnsk39zavkgVu2uLHR1mfAL%2BUd6iAJOofhlcjO%2FB%2FVAEwvqtQ7403Nqm6rGvy6%2FxHEiqvzvn42JADRxdGVFaw9SYyTi4QckGjG0OnG69mW2RBQdWOZ3FKmhJD6zWRPZVTbl7gJkpIdMZx0BbWKiYVsvJYgoCWNXIqqH77rigu5dsmEnWeC9J0Or1KaU%2Bzsd6QJwAzEwomhiGp3FII4wbGBnCiHLD%2FrtNgR%2BJ1H3bKgYkesdxuFvO5DzUc3eEOVBSwR0crd06J%2BJP4DolgWWNZN6ZmQ1s5aOQgSq&e=Access&y=Guest&t=&c="
        $url3 = "&c=&c=&c=&c=&c=&c=&c="
        $finalurl = $url1 + $odlid + $url3
        $WebClient.DownloadFile("$finalurl","C:\Packages\cloudlabsshadow.msi")
        Start-Process msiexec.exe -Wait '/I C:\Packages\cloudlabsshadow.msi /qn' -Verbose
    }
}

Function Enable-CloudLabsEmbeddedShadow($vmAdminUsername, $trainerUserName, $trainerUserPassword)
{
Write-Host "Enabling CloudLabsEmbeddedShadow"
#Created Trainer Account and Add to Administrators Group
$trainerUserPass = $trainerUserPassword | ConvertTo-SecureString -AsPlainText -Force

New-LocalUser -Name $trainerUserName -Password $trainerUserPass -FullName "$trainerUserName" -Description "CloudLabs EmbeddedShadow User" -PasswordNeverExpires
Add-LocalGroupMember -Group "Administrators" -Member "$trainerUserName"

#Add Windows regitary for enabl Shadow
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v Shadow /t REG_DWORD /d 2

#Download Shadow.ps1 and Shadow.xml file in VM
$drivepath="C:\Users\Public\Documents"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/cloudlabs-common/Shadow.ps1","$drivepath\Shadow.ps1")
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/cloudlabs-common/shadow.xml","$drivepath\shadow.xml")
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/cloudlabs-common/executetaskscheduler.ps1","$drivepath\executetaskscheduler.ps1")

#Replace vmAdminUsernameValue with VM Admin UserName in script content 
(Get-Content -Path "$drivepath\Shadow.ps1") | ForEach-Object {$_ -Replace "vmAdminUsernameValue", "$vmAdminUsername"} | Set-Content -Path "$drivepath\Shadow.ps1"
(Get-Content -Path "$drivepath\shadow.xml") | ForEach-Object {$_ -Replace "vmAdminUsernameValue", "$trainerUserName"} | Set-Content -Path "$drivepath\shadow.xml"
(Get-Content -Path "$drivepath\shadow.xml") | ForEach-Object {$_ -Replace "ComputerNameValue", "$($env:ComputerName)"} | Set-Content -Path "$drivepath\shadow.xml"

sleep 2

# Scheduled Task to Run Shadow.ps1 AtLogOn
schtasks.exe /Create /XML $drivepath\shadow.xml /tn Shadowtask

#$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
#Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String 
#Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\$trainerUserName" -type String  
#Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "$trainerUserPassword" -type String
#Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

#$Trigger= New-ScheduledTaskTrigger -AtLogOn, if above schedule task won't work then try below
#$User= "$($env:ComputerName)\$trainerUserName" 
#$Action= New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File C:\Users\Public\Documents\executetaskscheduler.ps1"
#Register-ScheduledTask -TaskName "executetaskscheduler" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force

}

#Create Azure Credential File on Desktop
Function CreateCredFile($AzureUserName, $AzurePassword, $AzureTenantID, $AzureSubscriptionID, $DeploymentID)
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/cloudlabs-common/AzureCreds.txt","C:\LabFiles\AzureCreds.txt")
    $WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/cloudlabs-common/AzureCreds.ps1","C:\LabFiles\AzureCreds.ps1")
    
    New-Item -ItemType directory -Path C:\LabFiles -force

    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
             
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"

    Copy-Item "C:\LabFiles\AzureCreds.txt" -Destination "C:\Users\Public\Desktop"
}

#Add Service Principle details to Azure Credential Files
Function SPtoAzureCredFiles($SPDisplayName, $SPID, $SPObjectID, $SPSecretKey, $AzureTenantDomainName)
{
    Add-Content -Path "C:\LabFiles\AzureCreds.txt" -Value "AzureServicePrincipalDisplayName= $SPDisplayName" -PassThru
    Add-Content -Path "C:\LabFiles\AzureCreds.txt" -Value "AzureServicePrincipalAppID= $SPID" -PassThru
    Add-Content -Path "C:\LabFiles\AzureCreds.txt" -Value "AzureServicePrincipalObjectID= $SPObjectID" -PassThru
    Add-Content -Path "C:\LabFiles\AzureCreds.txt" -Value "AzureServicePrincipalSecretKey= $SPSecretKey" -PassThru
    Add-Content -Path "C:\LabFiles\AzureCreds.txt" -Value "AzureTenantDomainName= $AzureTenantDomainName" -PassThru

    Add-Content -Path "C:\LabFiles\AzureCreds.ps1" -Value '$AzureServicePrincipalDisplayName="SPDisplayNameValue"' -PassThru
    Add-Content -Path "C:\LabFiles\AzureCreds.ps1" -Value '$AzureServicePrincipalAppID="SPIDValue"' -PassThru
    Add-Content -Path "C:\LabFiles\AzureCreds.ps1" -Value '$AzureServicePrincipalObjectID="SPObjectIDValue"' -PassThru
    Add-Content -Path "C:\LabFiles\AzureCreds.ps1" -Value '$AzureServicePrincipalSecretKey="SPSecretKeyValue"' -PassThru
    Add-Content -Path "C:\LabFiles\AzureCreds.ps1" -Value '$AzureTenantDomainName="AzureTenantDomainNameValue"' -PassThru

    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "SPDisplayNameValue", "$SPDisplayName"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "SPIDValue", "$SPID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "SPObjectIDValue", "$SPObjectID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "SPSecretKeyValue", "$SPSecretKey"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureTenantDomainNameValue", "$AzureTenantDomainName"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"

    Copy-Item "C:\LabFiles\AzureCreds.txt" -Destination "C:\Users\Public\Desktop" -force
}

#Install Cloudlabs Modern VM (Windows Server 2012,2016,2019, Windows 10) Validator
Function InstallModernVmValidator
{   
    #Create C:\CloudLabs\Validator directory
    New-Item -ItemType directory -Path C:\CloudLabs\Validator -Force
    Invoke-WebRequest 'https://experienceazure.blob.core.windows.net/software/vm-validator/VMAgent.zip' -OutFile 'C:\CloudLabs\Validator\VMAgent.zip'
    Expand-Archive -LiteralPath 'C:\CloudLabs\Validator\VMAgent.zip' -DestinationPath 'C:\CloudLabs\Validator' -Force
    Set-ExecutionPolicy -ExecutionPolicy bypass -Force
    cmd.exe --% /c @echo off
    cmd.exe --% /c sc create "Spektra CloudLabs VM Agent" BinPath=C:\CloudLabs\Validator\VMAgent\Spektra.CloudLabs.VMAgent.exe start= auto
    cmd.exe --% /c sc start "Spektra CloudLabs VM Agent"
}

#Install Cloudlabs Legacy VM (Windows Server 2008R2) Validator
Function InstallLegacyVmValidator
{
    #Create C:\CloudLabs
    New-Item -ItemType directory -Path C:\CloudLabs\Validator -Force
    Invoke-WebRequest 'https://experienceazure.blob.core.windows.net/software/vm-validator/LegacyVMAgent.zip' -OutFile 'C:\CloudLabs\Validator\LegacyVMAgent.zip'
    Expand-Archive -LiteralPath 'C:\CloudLabs\Validator\LegacyVMAgent.zip' -DestinationPath 'C:\CloudLabs\Validator' -Force
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory('C:\CloudLabs\Validator\LegacyVMAgent.zip','C:\CloudLabs\Validator')
    Set-ExecutionPolicy -ExecutionPolicy bypass -Force
    cmd.exe --% /c @echo off
    cmd.exe --% /c sc create "Spektra CloudLabs Legacy VM Agent" binpath= C:\CloudLabs\Validator\LegacyVMAgent\Spektra.CloudLabs.LegacyVMAgent.exe displayname= "Spektra CloudLabs Legacy VM Agent" start= auto
    cmd.exe --% /c sc start "Spektra CloudLabs Legacy VM Agent"

}

#Install SQl Server Management studio
Function InstallSQLSMS
{
    choco install sql-server-management-studio -y -force
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Microsoft SQL Server Management Studio 18.lnk")
    $Shortcut.TargetPath = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"
    $Shortcut.Save()

}

#Install Azure Powershell Az Module
Function InstallAzPowerShellModule
{
    <#Install-PackageProvider NuGet -Force
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module Az -Repository PSGallery -Force -AllowClobber#>

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://github.com/Azure/azure-powershell/releases/download/v5.0.0-October2020/Az-Cmdlets-5.0.0.33612-x64.msi","C:\Packages\Az-Cmdlets-5.0.0.33612-x64.msi")
    sleep 5
    Start-Process msiexec.exe -Wait '/I C:\Packages\Az-Cmdlets-5.0.0.33612-x64.msi /qn' -Verbose 

}

Function InstallAzCLI
{
    choco install azure-cli -y -force
}

Function InstallGoogleChrome
{

    choco install googlechrome -y -force

}

Function InstallVSCode
{

    choco install vscode -y -force

}

Function InstallGitTools
{

    choco install git.install -y -force

}

Function InstallPutty
{

    choco install putty.install -y -force

}

Function InstallAdobeReader
{

    choco install adobereader -y -force

}

Function InstallFirefox
{

    choco install firefox -y -force

}

Function Install7Zip
{

    choco install 7zip.install -y -force

}


Function InstallNodeJS
{

    choco install nodejs -y -force

}

Function InstallDotNet4.5
{

    choco install dotnet4.5 -y -force

}

Function InstallDotNetFW4.8
{

    choco install dotnetfx -y -force

}

Function InstallPython
{

    choco install python -y -force

}

Function InstallWinSCP
{

    choco install winscp.install -y -force

}

Function Installvisualstudio2019professional
{

    choco install visualstudio2019professional -y -force

}

Function Installvisualstudio2019community
{

    choco install visualstudio2019community -y -force

}
Function InstalldockerforWindows
{

    choco install docker-for-windows -y -force

}


Function InstallEdgeChromium
{
    #Download and Install edge
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/59c478d3-513a-4060-837b-01ad385d6aaa/MicrosoftEdgeEnterpriseX86.msi","C:\Packages\MicrosoftEdgeBetaEnterpriseX64.msi")
    sleep 5
    
    Start-Process msiexec.exe -Wait '/I C:\Packages\MicrosoftEdgeBetaEnterpriseX64.msi /qn' -Verbose 
    sleep 5
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Azure Portal.lnk")
    $Shortcut.TargetPath = """C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"""
    $argA = """https://portal.azure.com"""
    $Shortcut.Arguments = $argA 
    $Shortcut.Save()

}

Function Expand-ZIPFile($file, $destination)
{
$shell = new-object -com shell.application
$zip = $shell.NameSpace($file)
foreach($item in $zip.items())
    {
        $shell.Namespace($destination).copyhere($item)
}
}

Function Download($fileurl, $destination)
{
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("$fileurl","$destination")
}

Function ResizeOSDiskMax()
{
# Iterate through all the disks on the Windows machine
foreach($disk in Get-Disk)
{
# Check if the disk in context is a Boot and System disk
if((Get-Disk -Number $disk.number).IsBoot -And (Get-Disk -Number $disk.number).IsSystem)
{
    # Get the drive letter assigned to the disk partition where OS is installed
    $driveLetter = (Get-Partition -DiskNumber $disk.Number | where {$_.DriveLetter}).DriveLetter
    Write-verbose "Current OS Drive: $driveLetter :\"

    # Get current size of the OS parition on the Disk
    $currentOSDiskSize = (Get-Partition -DriveLetter $driveLetter).Size        
    Write-verbose "Current OS Partition Size: $currentOSDiskSize"

    # Get Partition Number of the OS partition on the Disk
    $partitionNum = (Get-Partition -DriveLetter $driveLetter).PartitionNumber
    Write-verbose "Current OS Partition Number: $partitionNum"

    # Get the available unallocated disk space size
    $unallocatedDiskSize = (Get-Disk -Number $disk.number).LargestFreeExtent
    Write-verbose "Total Unallocated Space Available: $unallocatedDiskSize"

    # Get the max allowed size for the OS Partition on the disk
    $allowedSize = (Get-PartitionSupportedSize -DiskNumber $disk.Number -PartitionNumber $partitionNum).SizeMax
    Write-verbose "Total Partition Size allowed: $allowedSize"

    if ($unallocatedDiskSize -gt 0 -And $unallocatedDiskSize -le $allowedSize)
    {
        $totalDiskSize = $allowedSize
        
        # Resize the OS Partition to Include the entire Unallocated disk space
        $resizeOp = Resize-Partition -DriveLetter C -Size $totalDiskSize
        Write-verbose "OS Drive Resize Completed $resizeOp"
    }
    else {
        Write-Verbose "There is no Unallocated space to extend OS Drive Partition size"
    }
}   
}
}

sleep 10

[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
Disable-InternetExplorerESC
Enable-IEFileDownload
Enable-CopyPageContent-In-InternetExplorer
InstallChocolatey
CreateLabFilesDirectory
DisableWindowsFirewall
InstallAzPowerShellModule
InstallAzCLI
InstallEdgeChromium
InstallVSCode
InstallPutty
Enable-CloudLabsEmbeddedShadow azureuser trainer Password.!!1
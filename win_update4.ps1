#Pre-Requisite
#1. Install Windows Update Management Module
#   Install-Module -Name PSWindowsUpdate
#2. Allow Script Execution
#   Set-ExecutionPolicy RemoteSigned
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#3. Import Module
#    Import-Module PSWindowsUpdate
#4. Show Modules
#   get-command-module PSWindowsUpdate
#   OR get-command-module PSWindowsUpdate
#    Get-Command -module PSWindowsUpdate
#5. configure hosts file
#   c:\windows\system32\drivers\etc\hosts
#6. Execute: winrm quickconfig on the remote machine


#Run this command before running the scripts
#cmd: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#cmd:  Set-ExecutionPolicy RemoteSigned
#cmd: Install-Module -Name PackageManagement -RequiredVersion 1.1.7.0
#cmd: Install-Module -Name PSWindowsUpdate -AllowClobber
#Get-Package -Name PSWindowsUpdate 
#cmd: get-command -module PSWindowsUpdate
#Enable-WURemoting
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
# Set-ExecutionPolicy RemoteSigned
#Get-ExecutionPolicy -List


#Notes: Running
#To output to a file
# win_update.ps1 > filename.txt

#Help
#Get Module
# Install-Module -Name PSWindowsUpdate
#Find-Module -Name PowerShellGet | Install-Module
Import-Module PSWindowsUpdate

#clear before querying
cls

Get-Process | Out-File -FilePath .\Process.txt

#Get-Module -Name *Update* 
Write-Output "`n`n"
Write-Output "-----------------------------------------------"
Write-Output "->Check Module To Check Device Before Patching "
Write-Output "-----------------------------------------------"
Write-Output "`n"
Get-Command -Module WindowsUpdateProvider
$PSVersionTable


#last Successful Update
Write-Output "`n`n"
Write-Output "->Local Computer Last Successful Update"
Get-WmiObject win32_operatingsystem | select Caption, Version
(New-Object -com "Microsoft.Update.AutoUpdate").Results


#local check updates
Write-Output "`n`n"
Write-Output "-------------------------------------"
Write-Output "->List Local Computer Latest Updates"
Write-Output "-------------------------------------"
Write-Output "`n"
wmic qfe list


# Requires Internet Access
# This module will access the internet to compare against your MS DB update to MS website where they store updates
Write-Output "`n`n"
Write-Output "-------------------------------------"
Write-Output "->List for Pending Update: Local Computer "
Write-Output "-------------------------------------"
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateupdateSearcher()
$Updates = @($UpdateSearcher.Search("IsHidden=0 and IsInstalled=0").Updates)
$Updates | Select-Object Title
#OR
#Allows you to download and install updates from the server WSUS or Microsoft Update
Get-WUList
Get-WUInstall -AcceptAll


# Review Update Pending Status to install
#Check the status of the Windows Install service
Get-WUInstallerStatus
# Check if reboot is necessary
Get-WUInstallerStatus

Write-Output "`n`n"
Write-Output "-------------------------------------"
Write-Output "->List HotFix of the local computer "
Write-Output "-------------------------------------"
Get-Hotfix

Write-Output "`n"
Write-Output "Get Most Recent HotFix"
Write-Output "--------------------------------------"
(Get-HotFix | Sort-Object -Property InstalledOn)[-1]



##########################
#LOCAL UPDATE ONLY       #
##########################
#Install Windows Update Now
# Requires Admin right

#Install Everythign without prompting
#Deploy updates to local Computers
Write-Output "`n`n"
Write-Output "-------------------------------------"
Write-Output "->Install Microsoft Update "
Write-Output "-------------------------------------"
Install-Module PSWindowsUpdate
Get-WindowsUpdate
Install-WindowsUpdate


#See if you need to reboot computer
##################################
#NEED REBOOT COMPUTER
#################################
Get-WUInstallerStatus
Get-WURebootStatus

####################################
# REMOTE COMPUTER PATCH UPDATE     #
####################################
# Perform Remote Update to computers
# List the names of the remote computer to be updated


$secureString = 'oka' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object pscredential('oka', $secureString)


###################################
#LOOP THROUGH THE REMOTE COMPUTERs
###################################
ForEach ($hostname in $args) { 

#Invoke-Command -ComputerName $hostname -ScriptBlock { Get-Host } -credential $credential
    Write-Output "Updating PSWindowUpdate..."
    # Install PSWindowsUpdate on target machine

   Invoke-Command -computername $hostname -ScriptBlock {
    
        Write-Output "-----------> Identify Host..."
        Get-Host
        Write-Output "..Done"
        Write-Output "`n"
        Write-Output "----------->Set Execution Policy Remotely..."
        Set-ExecutionPolicy RemoteSigned
        Write-Output "..Done"
        Write-Output "`n"
        Write-Output "------------->Get Package Provider and Run PSWindowsUpdate..."
        PackageManagement\Get-PackageProvider -Name NuGet -Force
        inmo PSWindowsUpdate -Force
        Write-Output "..Done"
        Write-Output "`n"

        Write-Output "------------->starting Tasks Name..CALLING scheduled patch update remotely."
        Start-ScheduledTask "windowsupdateremote"
        #Get-ScheduledTask -CimSession $hostname |  Where-Object {$_.state -match "Running"}

        Write-Output "..Done"
        Write-Output "`n"
        Write-Output "------------->Getting Hot Fix/Patch..."
        Get-HotFix

    } -Credential $credential 

   Write-Output "Processing Install the Updates..."


#------------------------------------------------------------------------------------------------------------------------------
    #MICROSOFT DISABLED THE REMOTE PATCH UPDATE WITH THE NEW POWERSHELL DUE TO SECURITY RISKS
    # WORKAROUND - CALLED SCHEDULED TASKS REMOTELY 
    #Install the Updates
    #Or if you want to install updates on multiple machine parallel use start-Job in order to execute the above PowerShell Code.
    #test it you will find that updates cannot be installed in a remote session. This is well documented and has been for years.
    #Invoke-WUJob -ComputerName $hostname -Script {
     #   Import-Module PSWindowsUpdate;
     #   ipmo PSWindowsUpdate;
     #   #Install-WindowsUpdate -install -AcceptAll -IgnoreReboot
    #} -Confirm:$false -verbose -RunNow
  }
#-----------------------------------------------------------------------------------------------------------------------------


  #Invoke-Command -ComputerName Orange -FilePath c:\Users\oka\Documents\t.ps1
 


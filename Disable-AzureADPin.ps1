#requires -version 4
<#
.SYNOPSIS
  Prevents Windows 10 prompting to setup a pin after being added to Azure AD
  Designed for use with Office 365 Business Premium subscriptions

.DESCRIPTION
  This script adds a registry value to disable PIN creation request and removes all PINs currently in the system. 
  

.NOTES
  Version:        1.0
  Author:         Ian Waters
  Creation Date:  Sept 2018
  Purpose/Change: Initial script development
  Source :        https://www.slashadmin.co.uk/how-to-disable-pin-requirements-when-joining-windows-10-pc-to-azure-ad-and-using-office365-business-premium/

.EXAMPLE
  <Example explanation goes here>
  
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  #Script parameters go here
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Disable pin requirement
$path = "HKLM:\SOFTWARE\Policies\Microsoft"
$key = "PassportForWork"
$name = "Enabled"
$value = "0"

#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

New-Item -Path $path -Name $key –Force
 
New-ItemProperty -Path $path\$key -Name $name -Value $value -PropertyType DWORD -Force
 
#Delete existing pins
$passportFolder = "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"
 
if(Test-Path -Path $passportFolder)
{
    # Change the letter Y to the one that says yes in your language should the system not be in english
    Takeown /f $passportFolder /r /d "Y"

    ICACLS $passportFolder /reset /T /C /L /Q
 
    Remove-Item –path $passportFolder –recurse -force
}
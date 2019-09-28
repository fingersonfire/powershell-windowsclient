#requires -version 4
#requires -RunAsAdministrator
<#
.SYNOPSIS
  Retreive the password for your wireless networks

.DESCRIPTION
  This script retreive your wireless password stored in your computer. It queries and parse the "netsh wlan show profiles" command. 


.NOTES
  Version:        1.0
  Author:         FingersOnFire
  Creation Date:  2019-09-26
  Purpose/Change: Initial script development
  Source: 
	- https://jocha.se/blog/tech/display-all-saved-wifi-passwords
	- https://devblogs.microsoft.com/scripting/get-wireless-network-ssid-and-password-with-powershell/

.EXAMPLE
  Simple Run. Returns all profiles and passwords
  
  Get-WifiPassword.ps1
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

$NetworkList = @()

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Get-WifiProfiles {
	return netsh wlan show profiles | Select-String "\:(.+)$" | %{$_.Matches.Groups[1].Value.Trim()}
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# One-Liner Equivalent
# (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }}

$ProfileList = Get-WifiProfiles

foreach($Profile in $ProfileList) {
	$ProfileInfo = netsh wlan show profiles name=$Profile key="clear";
	$SSID = $ProfileInfo | Select-String -Pattern "SSID Name\W+\:(.+)$" | %{ ($_ -split ":")[-1].Trim() };
	$Key = $ProfileInfo | Select-String -Pattern "Key Content\W+\:(.+)$" | %{($_ -split ":")[-1].Trim()};

	$NetworkList += [PSCustomObject]@{
		Profile = $Profile
		SSID = $SSID;
		Password = $Key
	}
}

$NetworkList
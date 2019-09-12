#requires -version 4
<#
.SYNOPSIS
  Get the content of an INI file

.DESCRIPTION
  Import the content of a INI file into a key / value array.

.PARAMETER FilePath
  The location of the INI file you want to parse

.INPUTS
  None

.OUTPUTS
  2 dimentions array (Rows are named Name and Value).

.NOTES
  Version:        1.0
  Author:         FingersOnFire
  Creation Date:  2019-05-02
  Purpose/Change: Initial script development

.EXAMPLE
  Simple usage
  
  Get-IniFileContent.ps1 -FilePath C:\Temp\inifile.ini
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param
(
	[parameter(Mandatory=$true)]
	[ValidateNotNull()]
	$FilePath
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Any Global Declarations go here

$GlobalSettings = @{}

$FileContent = ""


#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here


$FileContent = Get-Content $FilePath

foreach($line in $FileContent){ 
    $keyvalue = [regex]::split($line,'='); 

    if(($keyvalue[0].CompareTo("") -ne 0) -and ($keyvalue[0].StartsWith("[") -ne $True)) { 
        $GlobalSettings.Add($keyvalue[0], $keyvalue[1]) 
    } 
}

$GlobalSettings
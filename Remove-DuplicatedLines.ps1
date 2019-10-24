#requires -version 4
<#
.SYNOPSIS
  Remove duplicated Lines from Text File.

.DESCRIPTION
  This script removes duplicated lines from a text file but keeps the order of the line

.PARAMETER File
  The location of the text file

.INPUTS
  None

.OUTPUTS
  Deduplicated File. The file will be saved into the same directory with the suffix "-dedup"

.NOTES
  Version:        1.0
  Author:         FingersOnFire
  Creation Date:  2019-10-23
  Purpose/Change: Initial script development

.EXAMPLE
  Main Usage
  
  Remove-DuplicatedLines.ps1 -File C:\Temp\File.txt
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
		[Parameter(Position=0,mandatory=$true)]
        [string] $File
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# List of all the lines for the user
$lines = @()

# List of all unique lines names
$uniquelines = @()

#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------


write-host "Loading File content"
$lines = Get-Content $File

foreach($line in $lines)
{
	if($uniquelines.Contains($line)){
		write-host -ForegroundColor Red "DELETED:" $line
	}
	else{
		$uniquelines += $line
		write-host -ForegroundColor Green "KEPT:" $line
	}	
}


write-host "-----------------------------"
write-host "Total Lines:" $lines.Count
write-host "Total Lines kept:" $uniquelines.Count
write-host "-----------------------------"

$newfilename = [System.IO.Path]::GetDirectoryName($File) + "\" + [System.IO.Path]::GetFileNameWithoutExtension($File) + "-dedup.txt"
write-host "Saving File in :" $newfilename
$uniquelines | out-file $newfilename

write-host "All Done. Good bye."

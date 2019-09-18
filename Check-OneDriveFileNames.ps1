#requires -version 4
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None>

.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.EXAMPLE
  <Example explanation goes here>
  
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  [Parameter(Mandatory=$true)][string] $Folder,
  [switch]$Fix
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Unsupported character for OneDrive files or folders' names

$UnsupportedChars = '[!&{}~#%]'

#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

if(-Not (Test-Path $Folder)){
    Write-Host "$($Folder) does not exists" -ForegroundColor Red
    exit;
}
    

$items = Get-ChildItem -Path $Folder -Recurse

foreach ($item in $items){
    filter Matches($UnsupportedChars){
        $item.Name | Select-String -AllMatches $UnsupportedChars |
        Select-Object -ExpandProperty Matches
        Select-Object -ExpandProperty Values
    }

    $newFileName = $item.Name
    Matches $UnsupportedChars | ForEach-Object {
        
        Write-Host "$($item.FullName) has the illegal character $($_.Value)" -ForegroundColor Red

        if ($_.Value -match "&") { $newFileName = ($newFileName -replace "&", "and") }
        if ($_.Value -match "{") { $newFileName = ($newFileName -replace "{", "(") }
        if ($_.Value -match "}") { $newFileName = ($newFileName -replace "}", ")") }
        if ($_.Value -match "~") { $newFileName = ($newFileName -replace "~", "-") }
        if ($_.Value -match "#") { $newFileName = ($newFileName -replace "#", "") }
        if ($_.Value -match "%") { $newFileName = ($newFileName -replace "%", "") }
        if ($_.Value -match "!") { $newFileName = ($newFileName -replace "!", "") }
        
        if (($newFileName -ne $item.Name) -and ($Fix.IsPresent)){
            Rename-Item $item.FullName -NewName ($newFileName)
            Write-Host "$($item.Name) has been changed to $newFileName" -ForegroundColor Green
        }
    }
}
#requires -version 4
<#
.SYNOPSIS
  Batch split audio files

.DESCRIPTION
  Looks for audio files (like FLAC, APE, MP3,...) and Split them using their respective CUE files.
  The script looks for folder with single audio files and, should it also find a CUE file in it, run an external app to process it. 

  This script has been tested using CueTools 2.1.6 (It assumes CueTools folder is in the same directory as this script).
  Make sure to run CueTools first to set the options you like for the /convert parameter
  Also, since CueTools was not intended to be executed in batch mode, you will have to close the conversion window after each run.
  You could probably use MP3Split instead of CueTools.


.PARAMETER Path
  Root folder where to search for audio files

.INPUTS
  None

.OUTPUTS
  None - The script runs an external program to split the files

.NOTES
  Version:        1.0
  Author:         FingersOnFire
  Creation Date:  2020-02-18
  Purpose/Change: Initial script development

.EXAMPLE
  Simple Example 
  
  Split-AudioFile.ps1 -Path C:\Music
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
    [Parameter(Mandatory = $true)] 
    [string]$Path
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$AudioFileType = "*.flac"
$PlaylistFileType = "*.cue"
$FileCountInDir = 1
$SplitExePath = ".\CUETools_2.1.6\CUETools.exe"
$SplitExeParameter = "/Convert"
$Directories = @()

#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host
Write-Host "---------------------"
Write-Host "| LET'S SPLIT FILES |"
Write-Host "---------------------"

if(-not (Test-Path $Path  -PathType Container)){
    Write-Host "ERROR : Path does not exist"
    exit
}

Write-Host
Write-Host "Looking for files"
$Files = Get-Childitem –Path $Path -Include $AudioFileType -File -Recurse -ErrorAction SilentlyContinue

foreach($File in $Files){
    $Directories += Split-Path $File
}

Write-Host "Looking for directories with 1 file"
$FoldersWithUniqueFile = $Directories | Group-Object | Where{$_.Count -eq $FileCountInDir} | Select Name

Write-Host
Write-Host "-------"
Foreach ($Folder in $FoldersWithUniqueFile){

    $FolderContent = Get-Childitem –Path $Folder.Name -File

    $FlacFile = $FolderContent | Where {$_.Name -like $AudioFileType}
    $CueFile = $FolderContent | Where {$_.Name -like $PlaylistFileType}

    Write-Host "FOLDER: " $Folder.Name
    Write-Host "FLAC  : " $FlacFile
    Write-Host "CUE   : " $CueFile


    if(Test-Path $CueFile.FullName){
        Write-Host "SPLIT : " $FlacFile.FullName  
        & $SplitExePath $SplitExeParameter $CueFile.FullName | Out-Null
    }
    else{
        Write-Host "ERROR : File Missing"     
    }

    Write-Host "-------"    

}
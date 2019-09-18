#requires -version 4
<#
.SYNOPSIS
  Copy folder structure

.DESCRIPTION
  This tiny script copies a folder structure (no files) from a source directory to a target directory.
  

.PARAMETER sourceDir
  The source folder containing the folder structure you want to replicate
  
.PARAMETER targetDir
  The destination folder where the folder structure will be replicated

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        1.0
  Author:         FingersOnFire
  Creation Date:  20190918
  Purpose/Change: Initial script development

.EXAMPLE
  Copy-FolderStructure -sourceDir C:\Temp\Folder1 -targetDir C:\Temp\Folder2
  
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  [Parameter(Mandatory=$true)][string] $sourceDir,
  [Parameter(Mandatory=$true)][string] $targetDir
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------


#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

$rootFolders = Get-ChildItem -Path $sourceDir

foreach($folder in $rootFolders){	
	Copy-Item -Destination $targetDir -Filter {PSIsContainer} -Recurse -Container -Verbose
}
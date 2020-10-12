#requires -version 4
<#
.SYNOPSIS
  Split VCF file

.DESCRIPTION
  Explodes one single VCF file containing multiple contacts into multiple VCF files.
  Initialy intended to split Lotus Notes VCards but should work with other files.
  Source : https://quickclix.wordpress.com/2011/07/04/notesvcardexpor/

.PARAMETER VCard Path
  The path to the file you want to split into pieces.

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None>

.NOTES
  Version:        1.0
  Author:         Paul
  Creation Date:  2011-07-04
  Purpose/Change: Initial script development

.EXAMPLE
  Simple Example  
  .\Split-VCard.ps1 c:\vcf\joe.vcf
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

#Any Global Declarations go here

#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

clear-host
$ifile = $args[0]
If( $ifile -eq $NULL )
{
Write-Host Usage: .\Split-VCard.ps1 filename.vcf
Write-Host Examp: .\Split-VCard.ps1 c:\vcf\joe.vcf
Exit
}
Write-Host Processing vCard File: $ifile

$i = 1
switch -regex -file $ifile
{
"^BEGIN:VCARD" {if($FString){$FString |
out-file -Encoding "ASCII" "$ifile.$i.vcf"};$FString = $_;$i++}
"^(?!BEGIN:VCARD)" {$FString+="`r`n$_"}
}

Write-Host VCard Processing Complete
Write-Host Processed $i VCard entries 
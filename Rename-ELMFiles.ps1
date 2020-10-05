#requires -version 4
<#
.SYNOPSIS
  Rename ELM files based on their content

.DESCRIPTION
  You may get an export of emails in ELM format with non-relavant names.
  This scripts reads the content of a folder, open each ELM files it found and rename them with their dates and subject

  Source : https://pscustomobject.github.io/powershell/howto/PowerShell-Parse-Eml-File/

.PARAMETER FolderPath
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        1.0
  Author:         FingersOnFire
  Creation Date:  2020/09/06
  Purpose/Change: Initial script development

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

#Any Global Declarations go here

#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Get-EmlFile
{
<#
    .SYNOPSIS
        Function will parse an eml files.

    .DESCRIPTION
        Function will parse eml file and return a normalized object that can be used to extract infromation from the encoded file.

    .PARAMETER EmlFileName
        A string representing the eml file to parse.

    .EXAMPLE
        PS C:\> Get-EmlFile -EmlFileName 'C:\Test\test.eml'

    .OUTPUTS
        System.Object
#>
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $EmlFileName
    )

    # Instantiate new ADODB Stream object
    $adoStream = New-Object -ComObject 'ADODB.Stream'

    # Open stream
    $adoStream.Open()

    # Load file
    $adoStream.LoadFromFile($EmlFileName)

    # Instantiate new CDO Message Object
    $cdoMessageObject = New-Object -ComObject 'CDO.Message'

    # Open object and pass stream
    $cdoMessageObject.DataSource.OpenObject($adoStream, '_Stream')

    return $cdoMessageObject
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here

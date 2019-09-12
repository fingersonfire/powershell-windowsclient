#requires -version 4
<#
.SYNOPSIS
  Retrieve Windows Operating System Info using WMI

.DESCRIPTION
  Initial Source : https://superuser.com/questions/1330269/how-to-get-os-version-through-powershell-with-wmi
  Script Template : https://gist.github.com/9to5IT/d81802b28cfd10ab5d89
  This script should be run using administrative priviledges, preferably from a Domain Controller.

.PARAMETER ComputerName
  The network name of the computer you want to retrive information from.
  If not provided, the local computer name will be used

.INPUTS
  None

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\<name>.log

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
  [string]$ComputerName = $env:computername
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
Import-Module PSLogging

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#Log File Info
$sLogPath = 'C:\Temp'
$sLogName = 'ComputerInfo.log'
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

<#

Function <FunctionName> {
  Param ()

  Begin {
    Write-LogInfo -LogPath $sLogFile -Message '<description of what is going on>...'
  }

  Process {
    Try {
      <code goes here>
    }

    Catch {
      Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
      Break
    }
  }

  End {
    If ($?) {
      Write-LogInfo -LogPath $sLogFile -Message 'Completed Successfully.'
      Write-LogInfo -LogPath $sLogFile -Message ' '
    }
  }
}

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

$ScanDate = Get-Date -UFormat "%Y-%m-%d"
$ScanTime = Get-Date -UFormat "%T"

# Querying Infomation using WMI
$Manufacturer = Get-WmiObject -ComputerName $ComputerName -class win32_computersystem | select -ExpandProperty Manufacturer
$Model = Get-WmiObject -class win32_computersystem -ComputerName $ComputerName | select -ExpandProperty model
$Serial = Get-WmiObject -class win32_bios -ComputerName $ComputerName | select -ExpandProperty SerialNumber
$wmi_os = Get-WmiObject -class Win32_OperatingSystem -ComputerName $ComputerName | select CSName,Caption,Version,OSArchitecture,LastBootUptime
$wmi_cpu = Get-WmiObject -class Win32_Processor -ComputerName $ComputerName | select -ExpandProperty DataWidth
$wmi_memory = Get-WmiObject -class cim_physicalmemory -ComputerName $ComputerName | select Capacity | %{($_.Capacity / 1024kb)}
$DNName = Get-ADComputer -Filter "Name -like '$ComputerName'" | select -ExpandProperty DistinguishedName
$Boot=[System.DateTime]::ParseExact($($wmi_os.LastBootUpTime).Split(".")[0],'yyyyMMddHHmmss',$null)
[TimeSpan]$uptime = New-TimeSpan $Boot $(get-date)

# Matching OS Build
switch($wmi_os.Version){
'10.0.10240'{$wmi_build="1507"}
'10.0.10586'{$wmi_build="1511"}
'10.0.14393'{$wmi_build="1607"}
'10.0.15063'{$wmi_build="1703"}
'10.0.16299'{$wmi_build="1709"}
'10.0.17134'{$wmi_build="1803"}
'10.0.17686'{$wmi_build="1809"}
'10.0.17763'{$wmi_build="1809"}
}


# Creation of an object for easier manipulation of export
$properties = @{
    HostnameFromWMI = $($wmi_os.CSName)
    HostnameFromAD = $DNName
    Brand = $Manufacturer
    Model = $Model
    SN = $Serial
    OS = $($wmi_os.Caption)
    Build = $wmi_build
    Arch = $($wmi_os.OSArchitecture)
    OSVersion = $($wmi_os.Version)
    CPUArchitecture = $wmi_cpu
    Memory = $wmi_memory
    Uptime = "$($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
    ScanDate = $ScanDate
    ScanTime = $ScanTime
}
$OSInfo = New-Object psobject -Property $properties; 

# Retuning OSInfo Object
$OSInfo

# Stop-Log -LogPath $sLogFile
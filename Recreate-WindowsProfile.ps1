<#Corrupt Profile Fix v5 (Remote)
    By: xXGh057Xx and papa emeritus
    Source : https://community.spiceworks.com/scripts/show/2692-corrupt-profile-fix-v5-remote
#>

$ComputerName = Read-Host 'Hostname?'
$Username = Read-Host 'username?'
$Domain = Read-Host 'Domain?'
$filter = "name = " + "'$username'" + "AND domain = " + "'$Domain'"

#defines user profile key
$TargetKey = (Get-WMIObject -Class Win32_UserAccount -Filter $filter).sid

#sets rename values
$NewName = $TargetKey 
$NewBakName = $TargetKey + ".bad"

#sets working and broken reg paths
$GoodPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' + $TargetKey + '.bak'
$BadPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' + $TargetKey
Invoke-Command -computername $computername -ScriptBlock{
                 #back up registry 
                  REG EXPORT 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' C:\ProfileBackup.reg -y
                  Echo "Backed up registry to C:\ProfileBackup.reg"
}
$test = Invoke-Command -computername $computername -ScriptBlock{test-path -Path $using:GoodPath}
#Error check. It test that the good profile exsits as a .bak


#If key exists then it runs the repair.
If ($test -eq 'True')
{
  Invoke-Command -computername $computername -ScriptBlock{
                      #renames keys to fix profile
                       Rename-Item -Path $using:BadPath -NewName $using:NewBakName
                       Rename-Item -Path $using:GoodPath -NewName $using:NewName
                       #Fixes Values
    Set-ItemProperty -Path "$using:BadPath" -Name State -Value 000
    Set-ItemProperty -Path "$using:BadPath" -Name RefCount -Value 000
}
}

#If not it tells you no.
Else
{
  echo 'Only say yes if you know what your doing.'
  $KillProfile = Read-Host 'There seems to be no issue with your profile. Would you Like to kill the Profile? Y/N:'
    if ($KillProfile -eq 'Y')
    {
      #renames keys to fix profile
    Invoke-Command -computername $computername -ScriptBlock{Remove-Item -Path $using:BadPath -Recurse}
    }

       else 
       {
       
          Echo 'Good bye'
       }

}
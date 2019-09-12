# Source : https://social.technet.microsoft.com/Forums/en-US/afd16053-7db0-4a44-9499-be61851661bf/clean-pinned-start-menu-apps-with-powershell?forum=win10itprogeneral

# Warning : Partialy works according to its original author
# Author : Sebastiaan Castenmiller

############### Functions

function Pin-App { param(
 [string]$appname,
 [switch]$unpin
 )
 try{
 if ($unpin.IsPresent){
 ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'From "Start" UnPin|Unpin from Start'} | %{$_.DoIt()}
 return "App '$appname' unpinned from Start"
 }else{
 ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'To "Start" Pin|Pin to Start'} | %{$_.DoIt()}
 return "App '$appname' pinned to Start"
 }
 }catch{

 }
 }

 ############### Unpin All Apps
 
 Export-StartLayout –path C:\startscreenlayout.xml
 [xml]$layoutfile = Get-Content C:\startscreenlayout.xml

 foreach ( $item in $layoutfile.LayoutModificationTemplate.DefaultLayoutOverride.StartLayoutCollection.StartLayout.Group.DesktopApplicationTile.DesktopApplicationLinkPath)
 {
        $outputFile = Split-Path $item -leaf
        $name = $outputFile.split('.') | Select-Object -first 1
        Pin-App "$name" -unpin     
 }

 
 ############### PIN YOUR FAVORITE APPS
 Pin-App "Firefox" -pin
 Pin-App "Photos" -pin
 Pin-App "Calculator" -pin
 Pin-App "Snipping Tool" -pin
 Pin-App "Notepad" -pin
 Pin-App "File Explorer" -pin
 Pin-App "Word 2013" -pin
 Pin-App "Excel 2013" -pin
 Pin-App "Outlook 2013" -pin
 Pin-App "Powerpoint 2013" -pin
 Pin-App "Word 2016" -pin
 Pin-App "Excel 2016" -pin
 Pin-App "Outlook 2016" -pin
 Pin-App "Powerpoint 2016" -pin
# Author : CCraddock
# Source : https://gallery.technet.microsoft.com/scriptcenter/Reset-Home-Folder-Share-a4b42fc5

# This Powershell Script will Set home folder permissions so that only administrators and the user can access the files. 
# This script does not create the home folders for a user. To do that use this script: PLACEHOLDER
# The Variable $folderPath is the only one that needs changed. 
# Works best when ran on the server that hosts the home folder share. 

$FolderPath = "\\server\homefolder"

Write-Host "#Adding global Permissions    #" -ForegroundColor Green

foreach ($homeFolder in (Get-ChildItem $FolderPath | Where {$_.psIsContainer -eq $true})) {
    $homefolder
    $acl = Get-Acl $homefolder.FullName 
    $acl.Access | %{$acl.RemoveAccessRule($_)} 
    $acl.SetAccessRuleProtection($False, $True) 
    $Rights = [System.Security.AccessControl.FileSystemRights]::FullControl
    $inherit = [System.Security.AccessControl.FileSystemAccessRule]::ContainerInherit -bor [System.Security.AccessControl.FileSystemAccessRule]::ObjectInherit
    $Propagation = [System.Security.AccessControl.PropagationFlags]::None
    $Access = [System.Security.AccessControl.AccessControlType]::Allow
    $acct = New-Object System.Security.Principal.NTAccount("Builtin\Administrators") 
    $acl.SetOwner($acct) 
    Set-Acl $homefolder.FullName $acl
}

Write-Host "#Adding user specific Permissions    #" -ForegroundColor Green

foreach ($homeFolder in (Get-ChildItem $FolderPath | Where {$_.psIsContainer -eq $true})) {
    $homeFolder
    $acl = Get-Acl $homefolder.FullName
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($homefolder.Name,"Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl $homefolder.FullName $acl
}
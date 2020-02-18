$ComputerName = '' #replace with the computer name
$LMtype = [Microsoft.Win32.RegistryHive]::LocalMachine
$LMkey = "SYSTEM\CurrentControlSet\Control\Terminal Server"
$LMRegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($LMtype,$ComputerName)
$regKey = $LMRegKey.OpenSubKey($LMkey,$true)
If($regKey.GetValue("AllowRemoteRPC") -ne 1)
{
    $regKey.SetValue("AllowRemoteRPC",1)
    Start-Sleep -Seconds 1
}
$regKey.Dispose()
$LMRegKey.Dispose()
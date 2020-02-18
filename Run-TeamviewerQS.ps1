# To Execute Silently (Insert file path at the end)
# %windir%\System32\WindowsPowerShell\v1.0\powershell.exe -command PowerShell -ExecutionPolicy bypass -noprofile -windowstyle hidden -file <path_to_this_file>

$ProcessToKill = "TeamViewer"
$FileLocation = "" # Insert your custom Quick Support link here. You can copy it from the download page http://get.teamviewer.com/<quicksupportid> (Copy the Try Again Link)
$FileDestination = "$env:TEMP\twqs.exe" # This default location is C:\Users\Username\AppData\Local\Temp

# Stopping a process that might prevent execution
Stop-Process -Name $ProcessToKill -Force

#Downloading the File. Will overwrite any existing file
(New-Object System.Net.WebClient).DownloadFile($FileLocation,$FileDestination)

# Running the process
Start-Process ($FileDestination)
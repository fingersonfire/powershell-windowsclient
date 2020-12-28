$strComputer = "." 
 
$colItems = get-wmiobject -class "Win32_DCOMApplicationSetting" -namespace "root\CIMV2" -computername $strComputer 
 
$colItems
$Depth = 4
$Path = 'C:\'

$Levels = '/*' * $Depth
Get-ChildItem -Directory $Path/$Levels | ForEach-Object { ($_.FullName -split '[\\/]')[-$Depth] } | Select-Object -Unique
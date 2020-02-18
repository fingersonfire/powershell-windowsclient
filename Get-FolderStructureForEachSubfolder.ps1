$Depth = 3
$Path = 'C:\'

$Levels = '/*' * $Depth


$MainFolders = Get-ChildItem -Directory $Path

foreach($Folder in $MainFolders){

    Get-ChildItem -Directory $Folder.FullName/$Levels |
        ForEach-Object { ($_.FullName -split '[\\/]')[-$Depth] } |
        Select-Object -Unique 
        # |Export-Csv $OutputPath/$Folder.Name 

}
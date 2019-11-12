
$permissions = @()
$permissionsline = ""
$listseparator = ";"
$lines = Get-Content "C:\Program Files\FileZilla Server\FileZilla Server.xml"

foreach($line in $lines) {
    if($line -like '*<User Name=*'){

        if( ($permisionsline -ne "")){
            $permissions += $permissionsline; 
        }

        $permissionsline = $line.Trim().Replace("<User Name=" , '').Replace(">" , '') +  $listseparator

        
        # write-host $permissionsline
    }

    if($line -like '*<Permission Dir=*'){
        $permissionsline +=  $line.Trim().Replace("<Permission Dir=" , '').Replace(">" , '') +  $listseparator
    }

    # write-host $permissionsline
}

$permissions
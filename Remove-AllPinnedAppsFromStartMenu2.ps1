# Source : https://www.tenforums.com/customization/21002-how-automatically-cmd-powershell-script-unpin-all-apps-start.html
# Source : https://administrator.de/wissen/powershell-windows-10-modern-apps-startmen%C3%BC-anheften-entfernen-pin-unpin-287368.html

function Pin-App {
    param(
        [parameter(mandatory=$true)][ValidateNotNullOrEmpty()][string[]]$appname,
        [switch]$unpin
    )
    $actionstring = @{$true='Unpin from Start';$false='Pin to Start'}[$unpin.IsPresent]
    $action = @{$true='unpinned from';$false='pinned to'}[$unpin.IsPresent]
    $apps = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -in $appname}
    
    if($apps){
        $notfound = compare $appname $apps.Name -PassThru
        if ($notfound){write-error "These App(s) were not found: $($notfound -join ",")"}

        foreach ($app in $apps){
            $appaction = $app.Verbs() | ?{$_.Name.replace('&','') -match $actionstring}
            if ($appaction){
                $appaction | %{$_.DoIt(); return "App '$($app.Name)' $action Start"}
            }else{
                write-error "App '$($app.Name)' is already pinned/unpinned to/from start or action not supported."
            }
        }
    }else{
        write-error "App(s) not found: $($appname -join ",")"
    }
}

Pin-App "Mail" -unpin
Pin-App "Store" -unpin
Pin-App "Calendar" -unpin
Pin-App "Microsoft Edge" -unpin
Pin-App "Photos" -unpin
Pin-App "Cortana" -unpin
Pin-App "Weather" -unpin
Pin-App "Phone Companion" -unpin
Pin-App "Twitter" -unpin
Pin-App "Skype Video" -unpin
Pin-App "Candy Crush Soda Saga" -unpin
Pin-App "xbox" -unpin
Pin-App "Groove music" -unpin
Pin-App "movies & tv" -unpin
Pin-App "microsoft solitaire collection" -unpin
Pin-App "money" -unpin
Pin-App "get office" -unpin
Pin-App "onenote" -unpin
Pin-App "news" -unpin
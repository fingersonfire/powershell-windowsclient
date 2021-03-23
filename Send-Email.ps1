# Source : https://kimconnect.com/powershell-script-to-send-emails/
# This script has been edited to use manually, not as a commandlet. 

# This iteration includes the workaround for anonymous email relays
<#
# Examples:
# sendEmail john@contoso.com '' mary@contoso.com -cc $null test testEmail -smtpServer 'relay.contoso.com' -port 25 -useSsl $false -anonymous $true
# sendEmail -emailFrom $EmailUser -emailPassword $emailPassword `
            -emailTo 'admin@kimconnect.com' -cc $null `
            -subject "Test Email to Validate SMTP" -body "This is a test email.<br><br>Please disregard" `
            -smtpServer $smtpServer -port $port -attachments $attachments -useSsl $true
#>
 
$emailFrom=""
$emailPassword=""
$emailTo=""
$subject="TEST MESSAGE"
$body="This is a test email.<br><br>Please disregard"
$smtpServer=""
$port=587
$attachments=''
$useSsl=$true
 
function sendEmail{
    [CmdletBinding()]
    param(
    [Parameter(Mandatory)][string]$emailFrom,
    [Parameter(Mandatory)][string]$emailPassword,
    [Parameter(Mandatory)][string[]]$emailTo,    
    [Parameter(Mandatory=$false)][string[]]$cc,
    [Parameter(Mandatory=$false)]$subject="Test Email to Validate SMTP",
    [Parameter(Mandatory=$false)]$body="This is a test email.<br><br>Please disregard",
    [Parameter(Mandatory=$false)]$smtpServer=$null,
    [Parameter(Mandatory=$false)]$port=587,
    [Parameter(Mandatory=$false)]$attachments,
    [Parameter(Mandatory=$false)]$useSsl=$true,
    [Parameter(Mandatory=$false)]$anonymous=$false
    ) 
    $commonSmtpPorts=@(25,587,465,2525)
    function Check-NetConnection($server,$port,$timeout=100,$verbose=$false) {
        $tcp = New-Object System.Net.Sockets.TcpClient;
        try {
            $connect=$tcp.BeginConnect($server,$port,$null,$null)
            $wait = $connect.AsyncWaitHandle.WaitOne($timeout,$false)
            if(!$wait){
                $tcp.Close()
                if($verbose){
                    Write-Host "Connection Timeout" -ForegroundColor Red
                    }
                Return $false
            }else{
                $error.Clear()
                $null=$tcp.EndConnect($connect) # Dispose of the connection to release memory
                if(!$?){
                    if($verbose){
                        write-host $error[0].Exception.Message -ForegroundColor Red
                        }
                    $tcp.Close()
                    return $false
                    }
                $tcp.Close()
                Return $true
            }
        } catch {
            return $false
        }
    }
 
    function getMxRecord($emailAddress){
        $regexDomain="\@(.*)$"
        $domain=.{[void]($emailAddress -match $regexDomain);$matches[1]}
        $mxDomain=(resolve-dnsname $domain -type mx|sort -Property Preference|select -First 1).NameExchange
        $detectedSmtp=switch -Wildcard ($mxDomain){ # need to build up this list
                                "*outlook.com" {"smtp.office365.com";break}
                                "*google.com" {"smtp.gmail.com";break}
                                "*yahoodns.net" {'smtp.mail.yahoo.com';break}
                                "*inbox.com" {'my.inbox.com;break'}
                                "*mail.com" {'smtp.mail.com';break}
                                "*icloud.com" {'smtp.mail.me.com';break}
                                "*zoho.com" {'smtp.zoho.com';break}
                                default {$mxDomain}
                            }
        if($mxDomain){
            write-host "Detected MX Record`t: $mxDomain`r`nKnown SMTP Server`t: $detectedSmtp"
            return $detectedSmtp
            }
        else{
            write-warning "MX record not available for $emailAddress"
            return $null
            }
    }
     
    if($emailFrom -match '@' -and $emailPassword){
        $encryptedPass=ConvertTo-SecureString -String $emailPassword -AsPlainText -Force
        $emailCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $emailFrom,$encryptedPass
    }elseif($anonymous){
        $nullPassword = ConvertTo-SecureString 'null' -asplaintext -force
        $emailCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'NT AUTHORITY\ANONYMOUS LOGON', $pass
    }elseif($emailPassword){
        $emailCred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $emailFrom,$emailPassword
        [string]$emailFrom=$emailTo|select -First 1
    }else{
        $emailCred=$false
        }
 
    $detectedSmtpServer=if($emailFrom -match '@' -and !$anonymous){getMxRecord $emailFrom}else{$null}
    $smtpServer=if($smtpServer){
                    if($smtpServer -eq $detectedSmtpServer){
                        Write-host "Detected SMTP server matches the provided value: $smtpServer"
                    }else{
                        write-warning "Detected SMTP server $detectedSmtpServer does not match given values. Program will use the provided value: $smtpServer"
                        }
                    $smtpServer
                }else{
                    write-host "Using detected SMTP server $detectedSmtpServer"
                    $detectedSmtpServer
                    }
     
    $secureSmtpParams = @{        
        From                       = $emailFrom
        To                         = $emailTo
        Subject                    = $subject
        Body                       = $body
        BodyAsHtml                 = $true
        DeliveryNotificationOption = 'OnFailure','OnSuccess'
        Port                       = $port
        UseSSL                     = $useSsl
    }
 
    $relaySmtpParams=@{
        From                       = $emailFrom
        To                         = $emailTo
        Subject                    = $subject
        Body                       = $body
        BodyAsHtml                 = $true
        DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
        Port                       = 25
        UseSSL                     = $useSsl
    }
 
    if ($port -ne 25){
        write-host "Secure SMTP Parameters detected."
        $emailParams=$secureSmtpParams
    }else{
        write-host "Unsecured SMTP Parameters detected."
        $emailParams=$relaySmtpParams
        }
    write-host "$($emailParams|out-string)"
 
    try{
        $sendmailCommand="Send-MailMessage `@emailParams -SmtpServer $smtpServer $(if($cc){"-cc $cc"}) $(if($emailCred){"-Credential `$emailCred"}) $(if($attachments){"-Attachments `$attachments"}) -ErrorAction Stop"
        write-host $sendmailCommand
        Invoke-Expression $sendmailCommand
        write-host "Email has been sent to $emailTo successfully"
        return $true;
        }
    catch{
        #$errorMessage = $_.Exception.Message
        #$failedItem = $_.Exception.ItemName 
        #write-host "$errorMessage`r`n$failedItem" -ForegroundColor Yellow      
        Write-Warning "Initial attempt failed!`r`n$_`r`nNow scanning open ports..."
        $openPorts=$commonSmtpPorts|?{Check-NetConnection $smtpServer $_}                
        write-host "$smtpServer has these SMTP ports opened: $(if($openPorts){$openPorts}else{'None'})"
        if($detectedSmtpServer -ne $smtpServer){
            try{
                write-host "Program now attempts to use the detected SMTP Server: $detectedSmtpServer"
                Invoke-Expression "Send-MailMessage `@emailParams -SmtpServer $detectedSmtpServer $(if($attachments){"-Attachments $attachments"}) -ErrorAction Stop"
                write-host "Email has been sent to $emailTo successfully via alternative SMTP Server: $detectedSmtpServer" -ForegroundColor Green
                return $true;
            }catch{
                write-host $error[0].Exception.Message -ForegroundColor Yellow
                return $false
                }
        }else{
            return $false
            }        
        }
}

sendEmail -emailFrom $emailFrom -emailPassword $emailPassword `
            -emailTo $emailTo -cc $null `
            -subject $subject -body $body `
            -smtpServer $smtpServer -port $port -attachments $attachments -useSsl $false
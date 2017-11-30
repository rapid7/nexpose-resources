# Original author: pavedian

$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"
$server = '<ip address here>'
$api_version = '1.2'
$user = 'nxuser'
$SecurePassword = Get-Content C:\scripts\nexpose.txt | ConvertTo-SecureString
$Marshal = [System.Runtime.InteropServices.Marshal]
$Bstr = $Marshal::SecureStringToBSTR($SecurePassword)
$Password = $Marshal::PtrToStringAuto($Bstr)
$Marshal::ZeroFreeBSTR($Bstr)
$pwd = $Password
$uri = "https://${server}/api/${api_version}/xml"
$login_request = "<LoginRequest password ='$pwd' user-id = '$user' ></LoginRequest>"
$resp = Invoke-WebRequest -URI $uri -Body $login_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp.content
if($xmldata.LoginResponse.success -eq '0'){
    Write-Host 'ERROR: '$xmldata.LoginResponse.Failure.message -ForegroundColor Red
    }
    Else{
    $SCRIPT:session_id = $xmldata.LoginResponse.'session-id'
    Write-Host "Login Successful" -ForegroundColor Green
    }
$disc_request = "<DiscoveryConnectionListingRequest session-id='$SCRIPT:session_id'/>"
$resp_disc = Invoke-WebRequest -URI $uri -Body $disc_request -ContentType 'text/xml' -Method post
[xml]$xmldata = $resp_disc.content
$HTML = $xmldata.DiscoveryConnectionListingResponse.DiscoveryConnectionSummary |
Where{$_.'connection-status' -eq 'Disconnected' -or $_.'engine-id' -eq 3} | where {$_.'name' -ne 'Sonar'} |
ConvertTo-Html -As Table -Property Name,'Connection-Status','Engine-ID' -PreContent $Style
$HTML2 = $HTML -replace "<td>3</td>", "<td>Using Local Engine</td>"
if ($HTML2 -match 'Disconnected' -or $HTML2 -match "Using Local Engine"){
[string[]]$recipients = "First Last <first.last@company.com>", "First Last <first.last@company.com>"
Write-Host 'sending email'
send-mailmessage -to $recipients -from "nexpose@company.com" -subject "Nexpose Discovery Connections Alert!" -BodyAsHtml ($HTML2 | Out-String) -smtpserver <server address>
} else {
write-host "Nothing to see here.. move along"
}

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Replace with the server, username and password for your Nexpose install

$user = 'nxadmin'
$pwd = 'nxadmin'
$server = 'localhost'
$port = '3780'
$api_version = '1.1'
$uri = "https://${server}:${port}/api/${api_version}/xml"
$login_request = "<LoginRequest synch-id='0' password ='$pwd' user-id = '$user' ></LoginRequest>"

# login and get the session id
$resp = Invoke-WebRequest -URI $uri -Body $login_request -ContentType 'text/xml' -Method post
$session_id = $resp.content | Select-Xml -XPath '//@session-id' | Select-Object -ExpandProperty Node | foreach-object {$_.'#text'}

# Get a list of Sites
$sites_request = "<SiteListingRequest session-id='${session_id}'/>"
$resp = Invoke-WebRequest -URI $uri -Body $sites_request -ContentType 'text/xml' -Method post
$sites =  $resp.content | Select-XMl -XPath '//@name' | Select-Object -ExpandProperty Node | foreach-object {$_.'#text'}
Write-Output $sites

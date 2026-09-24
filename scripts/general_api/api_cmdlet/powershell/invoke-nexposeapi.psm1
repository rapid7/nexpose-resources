# Original author: Jeff Martin

Function Invoke-NexposeAPI
{

<#
.SYNOPSIS
    Run the specified API command, giving the required attributes as a hash array. Returns XML output from Nexpose
.NOTES
    The console's TLS certificate must be trusted by the machine running this cmdlet. If your console uses a
    self-signed certificate, import it into the local trust store (Cert:\LocalMachine\Root) rather than disabling
    validation.

    Do not set [System.Net.ServicePointManager]::ServerCertificateValidationCallback to bypass validation. That
    property is static on the AppDomain, so it applies to every subsequent outbound request in the PowerShell
    session -- not just this cmdlet's call -- and there is no indication it is in effect. On PowerShell 6 and
    later, Invoke-WebRequest -SkipCertificateCheck is correctly scoped to the single request if a bypass is
    genuinely needed.
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True)]
        [String]$Command,

        [Parameter()]
        $Fields,

         [Parameter(Mandatory=$True)]
          [String]$SessionID,

        [Parameter(Mandatory=$True)]
        [ValidateSet("1.1", "1.2")]
        [String]$APIVersion,

        [Parameter()]
        [String]$Server = "somehost",

        [Parameter()]
        [String]$Port = "3780"

    )

    Write-Debug (Format-Message -StartFunction)

    $URL = "https://${Server}:${Port}/api/${ApiVersion}/xml"

    # Create the base string for the XML, so we can add attributes to it later
    # We have to include a dummy attribute so Powershell casts the node as XML not string
    [xml]$RequestBody = "<$Command RemoveThis=`"null`" />"
    # Add the sessionID Attribute, then remove the dummy placeholder
    $RequestBody.$Command.SetAttribute("session-id",$SessionID)
    $RequestBody.$Command.RemoveAttribute("RemoveThis")



    #Add the rest of the attributes as submitted on cmd line
    If ( $Fields )
        {
        ForEach ( $Attribute in $Fields.Keys )
            {
            $RequestBody.$Command.SetAttribute($Attribute,$Fields.$Attribute)
            }
        }

    $Response = Invoke-WebRequest -URI $URL -Body $RequestBody -ContentType 'text/xml' -Method post

    # Should be some sort of error checking here


    Write-Output $Response


    Write-Debug (Format-Message -EndFunction)
  } # end of function
# Original author: Jeff Martin

Function Invoke-NexposeAPI
{

<#
.SYNOPSIS
    Run the specified API command, giving the required attributes as a hash array. Returns XML output from Nexpose
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

    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    $Response = Invoke-WebRequest -URI $URL -Body $RequestBody -ContentType 'text/xml' -Method post

    # Should be some sort of error checking here


    Write-Output $Response


    Write-Debug (Format-Message -EndFunction)
  } # end of function
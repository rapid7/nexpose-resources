Original author: Jeff Martin

---

Here is a short cmdlet I put together to use the API with powershell. You submit the command as a parameter and the required attributes as a hash array. I haven't gone through the bulk of the API yet, but so far it works with the commands I've wanted to use. It returns the output as XML, but once you have that in hand pulling out the data values isn't hard in PS

Examples:
```powershell
Invoke-NexposeAPI -APIVersion 1.1 -SessionID ABC123 -Command SiteListingRequest
```

```powershell
$Fields=@{}
$Fields.Add("site-id","1")
Invoke-NexposeAPI -APIVersion 1.1 -SessionID ABC123 -Fields $Fields -Command SiteDeviceListingRequest
```

## TLS certificates

The cmdlet talks to the console over HTTPS and relies on normal .NET certificate validation. The console's
certificate must be trusted by the machine you run this from.

If your console uses a self-signed certificate, import it into the local trust store:

```powershell
Import-Certificate -FilePath .\console.cer -CertStoreLocation Cert:\LocalMachine\Root
```

Do **not** disable validation by assigning to
`[System.Net.ServicePointManager]::ServerCertificateValidationCallback`. That property is static on the AppDomain:
setting it turns off certificate validation for *every* subsequent outbound request in the PowerShell session, not
just the console call, and nothing surfaces that it is in effect. An admin who runs this and then reuses the same
session for an Azure, AWS, or Microsoft 365 cmdlet silently loses TLS validation on those calls too.

If you genuinely need a bypass for a one-off test, PowerShell 6 and later support
`Invoke-WebRequest -SkipCertificateCheck`, which is scoped to the single request.

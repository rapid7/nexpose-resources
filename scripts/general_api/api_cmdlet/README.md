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

> **Breaking change for Windows PowerShell 5.1 users:** earlier versions of this cmdlet disabled certificate
> validation for the whole PowerShell session. That bypass has been removed. Consoles ship with a self-signed
> certificate by default, so if you have not trusted it you will now see
> `Could not establish trust relationship for the SSL/TLS secure channel`. Trust the console certificate as
> described below.

The cmdlet talks to the console over HTTPS and relies on normal .NET certificate validation. The console's
certificate must be trusted by the machine you run this from.

If your console uses a self-signed certificate:

1. Export it as `console.cer`: open `https://<console>:3780` in a browser, view the certificate, and export it
   (DER or Base-64 encoded).
2. On Windows, import it into your user's trusted root store. This needs no elevation:

   ```powershell
   Import-Certificate -FilePath .\console.cer -CertStoreLocation Cert:\CurrentUser\Root
   ```

   Use `Cert:\LocalMachine\Root` only if every user on the machine needs it; that requires an elevated session and
   trusts the certificate as a root CA for all users.

`Import-Certificate` and the `Cert:` drive are Windows-only. On PowerShell 7 on macOS or Linux, add the certificate
to the operating system trust store instead (for example Keychain Access on macOS, or `update-ca-certificates` on
Debian/Ubuntu).

Do **not** disable validation by assigning to
`[System.Net.ServicePointManager]::ServerCertificateValidationCallback`. On Windows PowerShell 5.1 that property is
static on the AppDomain: setting it turns off certificate validation for *every* subsequent outbound request in the
PowerShell session, not just the console call, and nothing surfaces that it is in effect. An admin who runs this and
then reuses the same session for an Azure, AWS, or Microsoft 365 cmdlet silently loses TLS validation on those calls
too.

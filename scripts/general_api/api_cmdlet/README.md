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
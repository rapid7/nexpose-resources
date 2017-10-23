Original author: pavedian

---

I was faced with a challenge recently.  We use DHCP Discovery connections and have automated actions set to scan items that have not been scanned in over a week.  Also, we scan any assets discovered that unknown to Nexpose.

Working with Discovery Connections can be frustrating.  When a discovery connection disconnects, it will likely time out after some time and won't try to reconnect itself.  It also will change the engine being used to 'local engine' if the engine if offline for any reason (especially when updating).  You can unknowingly reconnect all of your connections to the 'Local Scan Engine' if you are not careful.  This may not be a huge deal to some but for me it was.  We have over 30 Discovery Connections configured.  Since there is no alerting built in for this I decided to create my own.

Remember to generate the Secure String password to file prior to using this.  Once you have done so, you can schedule this script to run every hour.
The script checks for Engine ID 3 (Local Engine for my Console) and for any connections in a Disconnected State. Feel free to adjust as needed and to make suggestions.  I made this quickly to address the issue.

```powershell
#Use this to generate the secure string password to keep your password safe
#Remember to generate this with the account you plan to use for your scheduled task
#Only that account can convert it back to use for the scheduled task

$SecurePassword = Read-Host "Enter Password" -AsSecureString
$SecurePassword  | ConvertFrom-SecureString | Out-File c:\scripts\nexpose.txt
```
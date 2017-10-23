Original author: jaimie07

---

My company performs quarterly access reviews for all applications. Each application "owner" is required to provide a list of user accounts and their roles, submit that for review and remove/modify any user account necessary.

For this quarter, my security team required the list be generated from the system if possible. We do have a IAM tool that I am hoping I can integrate with eventually.

Because you can't export the user access list from Nexpose, I threw together the crude API script below to get the job done -- since I was only given a day to do it. I plan on updating it, but it might not happen until closer to the end of next quarter.

I've seen a few others requesting something like this on the community page. Unfortunately, whether you have custom roles or use default roles, there does not seem to be a way to pull the individual permissions from the roles, only the role titles. I also do not know if there is a way to get a list of the asset groups and sites that a user has permissions to, only the count of those.

This report returns a .csv file with output for UserID, FullName (first and last name), Admin (True or false, true is a global-admin role), Disabled (true or false), GroupCount (number of asset groups), SiteCount (number of sites), and Role (role title). The file name is UserList+current date and is saved to whatever folder your script is running from.

I use the User class and the User Summary class.

Feel free to give any suggestions on making it better. I will try to answer any questions, but I am a beginner myself.

Advice:
Run from the Nexpose console. Otherwise "host" needs to be changed to the IP of your server that Nexpose is running on
Run with a global admin account. It may not run for lesser privileges.

Hope this helps!
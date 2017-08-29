# Contributing to Nexpose Resources

Fork the repository, clone your fork to your local system, create a new branch and then start adding or making changes. When it's ready to be reviewed, push your changes up to your fork and then open a pull request.

Please include the following items in your pull request:

### License

This can either be a full copy of a license file, or simply a reference to a specific license. If you need help choosing a license be sure to visit these sites: https://choosealicense.com/ and https://opensource.org/licenses

You can put the license name inside your script or resource file, next to author information, or in the readme file.

### Readme file

The readme file can be in any format you like, though we prefer formats that can be rendered on Github. You can see the supported formats here: https://github.com/github/markup#markups

Please avoid using formats like Microsoft Word, RTF, PDF, or other "heavy" document types.

Your readme file should describe what your resource is and how to use it, with examples if necessary.

### Resource file(s)

For scripts it is simple enough to ensure the filename has the appropriate extension, such as `.rb` for Ruby, `.py` for Python, etc.

For SQL Queries you can save as `.txt` or `.sql` - the latter will provide nice formatting when viewing on Github.

If your resource requires users to replace some variables be sure to note that with code comments. Avoid including default usernames, passwords, hostnames, or IP addresses. If an example must be provided they should not resolve to real things on the Internet. You may use `example.com` for a hostname or `127.0.0.1`, `192.168.0.1`, `10.0.0.1`, and similar private ranges for IP addresses.

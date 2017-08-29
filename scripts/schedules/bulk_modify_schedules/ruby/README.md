A script to enable, disable, or delete schedules on multiple or all sites at once.

License: [MIT](./LICENSE)

Usage:

```
Usage: bulk_modify_schedules.rb [options] <action> <site IDs>

Enable, disable, or delete all scan schedules. Optional: Specify site IDs separated by commas.
Valid actions are: enable, disable, delete.

Note that this script will always prompt for a connection password.

Options:
    -H, --host [HOST]                IP or hostname of Nexpose console. Default: localhost
    -p, --port [PORT]                Port of Nexpose console. Default: 3780
    -u, --user [USER]                Username to connect to Nexpose with. Default: nxadmin
    -d, --dry-run                    Output sites to modify, but do not actually modify them.
    -h, --help                       Print this help message.
```
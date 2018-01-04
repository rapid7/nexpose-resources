## Site Scan Export/Import Example
These scripts are intended to show how to use the `nexpose` ruby gem in order to export scans from a site and import them 
into another site and/or Nexpose console.  They will need to be modified more if advanced features are needed.

#### export-site-scans.rb
Run the script by passing in the site ID where scans should be exported from:
```
> ruby export-site-scans.rb 1
```

This script results in a site.json file being generated with details about the site that was exported (eg scan template, 
name, etc) in addition to all the zipped scan files for the site.  An index is used to keep track of scan order (oldest 
to newest) since the import of scans must follow the same order.

#### import-site-scans.rb
Run the script without passing any arguments:
```
> ruby import-site-scans.rb
```

This script results in the site being created in the secondary console (will fail if site name already in use) with a 
name appended with '-import'.  The import defines `local scan engine` for site use and can be used as an example of how 
configurations can be overridden during the site creation.

In addition, each scan file is imported (oldest to newest) with sleeps added to ensure the import is complete prior to 
moving on.  

It is also possible to create the site manually prior to the import, comment out line 14 and 15, and add the following 
with proper site ID defined for import to line 16:
```
site_id = 2
```

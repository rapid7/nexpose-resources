#!/usr/bin/evn ruby  
require 'nexpose'
  
nsc = Nexpose::Connection.new('localhost-primary', 'nxadmin', 'nxpassword', '3780')
nsc.login  
at_exit { nsc.logout }  
  
# Allow the user to pass in the site ID to the script.  
site_id = ARGV[0].to_i  
  
# Write the site configuration to a file.  
site = Nexpose::Site.load(nsc, site_id)
File.write('site.json', site.to_json)
  
# Grab scans and sort by scan end time  
scans = nsc.site_scan_history(site_id).sort_by { |s| s.end_time }.map { |s| s.scan_id }  
  
# Scan IDs are not guaranteed to be in order, so use a proxy number to order them.  
i = 0  
scans.each do |scan_id|  
  nsc.export_scan(scan_id, "scan-#{i}.zip")  
  i += 1  
end  

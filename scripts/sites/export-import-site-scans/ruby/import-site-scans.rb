#!/usr/bin/evn ruby  
require 'nexpose'
  
nsc = Nexpose::Connection.new('localhost-secondary', 'nxadmin', 'nxpassword', '3780')
nsc.login  
at_exit { nsc.logout }  
 
site_bak = JSON.parse(File.read('site.json'), symbolize_names: true)
site = Nexpose::Site.from_hash(site_bak)
site.id = -1 
# Set to use the local scan engine.
site.name = "#{site.name}-import"
site.engine_id = nsc.engines.find { |e| e.name == 'Local scan engine' }.id  
site_id = site.save(nsc)
puts "Created Site: #{site.name}"
  
# Import scans by numerical ordering  
scans = Dir.glob('scan-*.zip').map { |s| s.gsub(/scan-/, '').gsub(/\.zip/, '').to_i }.sort  
scans.each do |scan|  
  zip = "scan-#{scan}.zip"  
  puts "Importing #{zip}"  
  nsc.import_scan(site_id, zip)
  # Poll until scan is complete before attempting to import the next scan.  
  last_scan = nsc.site_scan_history(site_id).max_by { |s| s.start_time }.scan_id
  puts "...#{nsc.scan_status(last_scan)}"
  sleep 60 # Give it plenty of time before importing next
  while (%w(running integrating).include?(nsc.scan_status(last_scan)))
    puts "...#{nsc.scan_status(last_scan)}"
    sleep 60 # Give it plenty of time before importing next
  end
  puts "Integration of #{zip} complete"  
end  

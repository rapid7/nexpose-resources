#!/usr/bin/env ruby

# Add lib to load path to use client without installing gem
lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))

if File.exist?(File.join(lib_dir, 'rapid7_vm_console.rb'))
  $LOAD_PATH.unshift lib_dir
else
  abort('ABORT: rapid7_vm_console.rb not on path or gem not installed')
end

require 'base64'
require 'yaml'

# Generated swagger client
require 'rapid7_vm_console'

settings = YAML.load_file('../settings.yml')

config = Rapid7VmConsole::Configuration.new()
config.scheme = 'https'
config.host=settings[:console][:host]
config.username = settings[:console][:user]
config.password = settings[:console][:pass]
config.verify_ssl = settings[:console][:verify_ssl]
config.verify_ssl_host = settings[:console][:verify_ssl_host]
if settings[:console][:debug]
  config.logger = Logger.new(STDOUT)
  config.debugging = true
end

client = Rapid7VmConsole::ApiClient.new(config)
client.default_headers['Authorization'] = "Basic #{Base64.strict_encode64("#{config.username}:#{config.password}")}"

site_client = Rapid7VmConsole::SiteApi.new(client)

done = false
site_to_scan = 'Example'

opts = {page: 0, size: 10}
until done
  sitesPage = site_client.get_sites(opts)

  sitesPage.resources.each do |site|
    if site.name.eql?(site_to_scan)
      puts "Found Site [#{site.name}]; Starting Scan..."

      # Run Scan
      scan_client = Rapid7VmConsole::ScanApi.new(client)
      scan_opts = {name: "Example Scan #{DateTime.now}", templateId: 'discovery'}
      scan_reference = scan_client.start_scan(site.id, {param1: scan_opts})

      # Check Scan Status
      scan_done = false

      until scan_done
        scan_status = scan_client.get_scan(scan_reference.id)

        if %w(aborted finished stopped error).include?(scan_status.status)
          scan_done = true
        else
          sleep(10)
        end

        puts "Scan Name [#{scan_status.scan_name}] status: #{scan_status.status}"
      end

      done = true
    end
  end


  opts[:page] += 1
  done = true if sitesPage.page.total_pages <= opts[:page]
end
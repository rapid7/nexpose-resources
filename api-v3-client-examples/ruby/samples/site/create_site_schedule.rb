#!/usr/bin/env ruby

# Add lib to load path to use client without installing gem
lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))

if File.exist?(File.join(lib_dir, 'rapid7_vm_console.rb'))
  $LOAD_PATH.unshift lib_dir
else
  abort('ABORT: rapid7_vm_console.rb not on path or gem not installed')
end

require 'base64'
require 'time'
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
site_in_scope = 'Example'

opts = {page: 0, size: 10}
until done
  sites_page = site_client.get_sites(opts)

  sites_page.resources.each do |site|
    if site.name.eql?(site_in_scope)
      puts "Found Site [#{site.name}]; Creating Schedule..."

      # Create Scan Schedule
      attributes = { :scanName => 'Scripted Schedule',
                     :start => Time.new(2018, 6, 10, 8, 00, 00, "-05:00").iso8601,
                     :onScanRepeat => 'restart-scan',
                     :scanEngineId => 1,
                     :scanTemplateId => 'discovery',
                     :enabled => true }
      site_schedule = Rapid7VmConsole::ScanSchedule.new(attributes)

      begin
        puts site_client.create_site_scan_schedule(site.id, {:param0 => site_schedule.to_hash})
      rescue Rapid7VmConsole::ApiError => re
        puts re.response_body
      rescue Exception => e
        puts e
      end

      done = true
    end
  end


  opts[:page] += 1
  done = true if sites_page.page.total_pages <= opts[:page]
end
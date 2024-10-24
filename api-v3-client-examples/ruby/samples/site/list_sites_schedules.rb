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

opts = {page: 0, size: 10}
until done
  sites_page = site_client.get_sites(opts)

  sites_page.resources.each do |site|
    puts "Site: #{site.name}"
    site_client.get_site_scan_schedules(site.id).resources.each do |site_schedule|
      puts "  Schedule Name: #{site_schedule.scan_name}"
      puts "  -- Template: #{site_schedule.scan_template_id}; Enabled: #{site_schedule.enabled}"
      puts "  -- Repeat: #{site_schedule.repeat.nil? ? 'None' : site_schedule.repeat.every}"

      schedule = site_client.get_site_scan_schedule(site.id, site_schedule.id)
      if schedule.assets.nil?
        puts "  -- Scope: ALL"
      else
        puts "  -- Scope: Sub #{schedule.assets}"
      end
    end
  end

  opts[:page] += 1
  done = true if sites_page.page.total_pages <= opts[:page]
end
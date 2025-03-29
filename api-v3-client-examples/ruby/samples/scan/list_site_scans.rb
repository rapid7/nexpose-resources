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

scan_client = Rapid7VmConsole::ScanApi.new(client)
site_client = Rapid7VmConsole::SiteApi.new(client)

site_in_scope = 'Example'
site_id = site_client.get_sites.resources.select{|site| site.name.eql?(site_in_scope)}.first.id

done = false

opts = {page: 0, size: 10}
until done
  scans_page = scan_client.get_site_scans(site_id, opts)

  scans_page.resources.each do |scan|
    puts "Scan Name: #{scan.scan_name}; Link: #{scan.links.select{|link| link.rel.eql?('self')}.first.href}"
  end

  opts[:page] += 1
  done = true if scans_page.page.total_pages <= opts[:page]
end
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

# Create api client and set Authorization header for basic auth
client = Rapid7VmConsole::ApiClient.new(config)
client.default_headers['Authorization'] = "Basic #{Base64.strict_encode64("#{config.username}:#{config.password}")}"

# Define list of included addresses
addresses = Rapid7VmConsole::IncludedScanTargets.new({:addresses => ['10.3.23.200','10.3.23.201','10.3.23.202']})
# Set list of addresses as target for static site
assets = Rapid7VmConsole::StaticSite.new({:includedTargets => addresses})
# Set scan scope for site
scan = Rapid7VmConsole::ScanScope.new({:assets => assets})

# Define attributes and create new site
attributes = {:description => 'Example Description', :name => 'Example', :scan => scan}
site = Rapid7VmConsole::SiteCreateResource.new(attributes)

# Create Site
begin
  # Save site with api
  site_client = Rapid7VmConsole::SiteApi.new(client)
  site_reference = site_client.create_site({:param0 => site})

  puts "Site ID: #{site_reference.id}"
  puts "Site link: #{site_reference.links.select{|link|link.rel.eql?('Site')}.first.href}"
rescue Rapid7VmConsole::ApiError => re
  puts re.response_body
rescue Exception => e
  puts e
end

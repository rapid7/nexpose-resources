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
  begin
    sites_page = site_client.get_sites(opts)
  rescue Rapid7VmConsole::ApiError => re
    puts re.response_body
    exit
  rescue Exception => e
    puts e
    exit
  end

  sites_page.resources.each do |site|
    puts "Site Name: #{site.name}; Link: #{site.links.select{|link| link.rel.eql?('self')}.first.href}"
  end

  opts[:page] += 1
  done = true if sites_page.page.total_pages <= opts[:page]
end
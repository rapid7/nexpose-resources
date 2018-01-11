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

report_name = 'Example Assets Query'
report_query = <<~SQL
  select * from dim_asset
SQL

report_client = Rapid7VmConsole::ReportApi.new(client)
site_client = Rapid7VmConsole::SiteApi.new(client)

site_in_scope = 'Example'
site_id = site_client.get_sites.resources.select{|site| site.name.eql?(site_in_scope)}.first.id

scope = Rapid7VmConsole::ReportConfigScopeResource.new({sites: [site_id]})
report_config = Rapid7VmConsole::Report.new(name: report_name, format: 'sql-query', scope: scope, query: report_query, version: '2.3.0')

begin
  response = report_client.create_report({:param0 => report_config})
  puts response
rescue Exception => e
  puts e.response_body
end
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

credential_client = Rapid7VmConsole::CredentialApi.new(client)
site_client = Rapid7VmConsole::SiteApi.new(client)

site_in_scope = 'Example'
site_id = site_client.get_sites.resources.select{|site| site.name.eql?(site_in_scope)}.first.id

begin
  account = Rapid7VmConsole::SharedCredentialAccount.new(service: 'ssh', username: 'username', password: 'password')
  shared_credential = Rapid7VmConsole::SharedCredential.new(account: account, description: 'Example SSH Credential',
                                                       name: 'Example SSH', siteAssignment: 'specific-sites', sites: [site_id])
  puts credential_client.create_shared_credential({:param0 => shared_credential})
rescue Rapid7VmConsole::ApiError => re
  puts re.response_body
rescue Exception => e
  puts e
end
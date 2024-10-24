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
report_client = Rapid7VmConsole::ReportApi.new(client)

done = false
opts = {page: 0, size: 10}

until done
  reportsPage = report_client.get_reports()

  reportsPage.resources.each do |report|
    if report.name.eql?(report_name)
      puts "Found Report Configuration [#{report.name}]; Generating Report..."

      # Generate Report
      report_instance = report_client.generate_report(report.id)

      # Check report status
      report_done = false

      until report_done
        report_instance_status = report_client.get_report_instance(report.id,report_instance.id)

        if %w(aborted failed complete).include?(report_instance_status.status)
          report_done = true

          # Download report
          report_contents = report_client.download_report(report.id,report_instance.id)
          # Save contents or process
          puts report_contents
        else
          sleep(5)
        end

        puts "Report Name [#{report.name}] status: #{report_instance_status.status}"
      end

      done = true
    end
  end

  opts[:page] += 1
  done = true if reportsPage.page.total_pages <= opts[:page]
end
#!/usr/bin/env ruby

# MIT License
# Copyright (c) 2017 Rapid7, Inc.

gem 'nexpose', '>= 5'
require 'nexpose'
require 'optparse'
require 'io/console'
require 'time'
require 'logger'

ARGV << '--help' if ARGV.empty?

host = '127.0.0.1'
port = '3780'
user = 'nxadmin'
@dry_run = false
@log = Logger.new($stdout)
actions = ['enable', 'disable', 'delete']

OptionParser.new do |opts|
  opts.banner = "Usage: #{File::basename($0)} [options] <action> <site IDs>"
  opts.separator ''
  opts.separator 'Enable, disable, or delete all scan schedules. Optional: Specify site IDs separated by commas.'
  opts.separator "Valid actions are: #{actions.join(', ')}."
  opts.separator ''
  opts.separator 'Note that this script will always prompt for a connection password.'
  opts.separator ''
  opts.separator 'Options:'
  opts.on('-H', '--host [HOST]', 'IP or hostname of Nexpose console. Default: localhost') { |h| host = h }
  opts.on('-p', '--port [PORT]', Integer, 'Port of Nexpose console. Default: 3780') { |p| port = p }
  opts.on('-u', '--user [USER]', 'Username to connect to Nexpose with. Default: nxadmin') { |u| user = u }
  opts.on('-d', '--dry-run', 'Output sites to modify, but do not actually modify them.') { @dry_run = true }
  opts.on_tail('-h', '--help', 'Print this help message.') { puts opts; exit }
end.parse!

unless ARGV[0]
  $stderr.puts 'Action is required. Valid actions are: #{actions.join(', ')}. Use --help for instructions.'
  exit(1)
end

unless actions.include?(ARGV[0])
  $stderr.puts "Action is required. Valid actions are: #{actions.join(', ')}. Use --help for instructions."
  exit(1)
end

@action = ARGV[0]
site_ids = []

if ARGV[1]
  site_ids = ARGV[1].split(',').map(&:to_i)
  site_ids.reject! { |id| id < 1 }
  @log.info "Site IDs: #{site_ids.join(', ')}"
end

def get_password(prompt="Password: ")
  print prompt
  STDIN.noecho(&:gets).chomp
end

def modify_site_schedule(nsc, site_id)
  site = Nexpose::Site.load(nsc, site_id)
  return if site.schedules.empty?
  case @action
  when 'enable'
    @log.info "Enabling #{site.schedules.size} schedule(s) for '#{site.name}' (#{site.id})."
    site.schedules.each { |sched| sched.enabled = true }
  when 'disable'
    @log.info "Disabling #{site.schedules.size} schedule(s) for '#{site.name}' (#{site.id})."
    site.schedules.each { |sched| sched.enabled = false }
  when 'delete'
    @log.info "Deleting #{site.schedules.size} schedule(s) for '#{site.name}' (#{site.id})."
    site.schedules = []
  else
    @log.warn "Invalid action: #{@action}"
    return
  end
  if @dry_run == false
    @log.info "Saving changes to '#{site.name}' (#{site.id})."
    site.save(nsc)
  else
    @log.info "*** Dry run *** Not saving changes to '#{site.name}' (#{site.id})."
  end
end

password = get_password

@log.info "\nConnecting to #{host}:#{port} as #{user}..."
nsc = Nexpose::Connection.new(host, user, password, port)

if @dry_run == true
  @log.info '*** Dry run enabled. No schedules will be modified. ***'
end

@log.info "Action to perform: #{@action}"

nsc.login
at_exit { nsc.logout }

if site_ids.empty?
  sites = nsc.list_sites
  sites.each do |site|
    begin
      modify_site_schedule(nsc, site.id)
    rescue Nexpose::APIError => e
      @log.warn "Site #{site.id} '#{site.name}'' failed: #{e.message}"
      next
    end
  end
else
  site_ids.each do |site_id|
    begin
      modify_site_schedule(nsc, site_id)
    rescue Nexpose::APIError => e
      @log.warn "Site ID #{site_id} failed: #{e.message}"
      next
    end
  end
end

@log.info 'Finished.'
exit(0)
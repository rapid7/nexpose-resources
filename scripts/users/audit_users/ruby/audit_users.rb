#!/usr/bin/env ruby

# Original author: jaimie07

require 'nexpose'
require 'csv'
require 'io/console'

include Nexpose

#insert console host ip instead of localhost if you are running from any other machine
host = 'localhost'

user=''
password=''

#requests user to provide their Nexpose username
if user == ''
  print 'User: '
  user = gets.chomp
end

#masks the password text
def get_password(prompt='Password: ')
  print prompt
  STDIN.noecho(&:gets).chomp
end

#requests user to provide their Nexpose password
if password == ''
  password = get_password
end

#log in to Nexpose and initiate connection
nsc = Connection.new(host, user, password)
nsc.login
at_exit { nsc.logout }

puts ''

#pulls user account list from Nexpose console into an array
users = nsc.list_users

#Creates .csv file named "UserList.csv" in the folder you are running the script
CSV.open("UserList_#{Time.now.strftime('%Y-%m-%d')}.csv", 'wb') do |csv|

  #sets the column headers for the csv
  csv<<['UserID', 'FullName', 'Admin', 'Disabled', 'GroupCount', 'SiteCount', 'Role']

  #loop to iterate through user list array
  users.each do |user|

  #creates a value to use the User class attributes
  uo = User.load(nsc,user.id)

  #writes user account attributes to rows
        csv << ["#{user.name}", "#{user.full_name}", "#{user.is_admin}", "#{user.is_disabled}", "#{user.group_count}", "#{user.site_count}", "#{uo.role_name}"]
  end
end

puts 'File created'
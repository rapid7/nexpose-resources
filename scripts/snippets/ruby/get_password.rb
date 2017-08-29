#!/usr/bin/env ruby

# An example of securely getting a password input from CLI without extra gems required

require 'io/console'

def get_password(prompt="Password: ")
  print prompt
  STDIN.noecho(&:gets).chomp
end

@password = get_password

# just an example, don't actually do this!
puts "\nYou entered #{@password}"
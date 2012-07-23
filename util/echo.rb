#!/usr/bin/env ruby

# a utility to class to echo a string and wait for input, allowing automated
# testing of the VT module

class Echo
  def initialize
    puts gets
  end
end

if __FILE__ == $0
  Echo.new
end

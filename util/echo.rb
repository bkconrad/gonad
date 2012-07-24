#!/usr/bin/env ruby

# a utility to echo a string and wait for input, allowing automated
# testing of the VT module

class Echo
  def initialize
    input = ""
    while input != "\n"
      input = STDIN.getc
      print input
    end
  end
end

if __FILE__ == $0
  Echo.new
end

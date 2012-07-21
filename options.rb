#!/usr/bin/env ruby
require "optparse"

# Simple options wrapper to allow future transparency of config files and command
# line options.

module Options
  attr_reader :options

  # parse arguments from ARGV

  def self.parse
    @options = ARGV.getopts("","loglevel:","wizard")
  end

  # get the value of an option. this is a string or nil for options which take
  # an argument, and true or false for boolean options

  def self.get option
    @options[option]
  end
end

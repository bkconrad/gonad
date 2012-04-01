#!/usr/bin/env ruby
require "optparse"
require "./local"
require "./debug"
require "./parser"

$options = {}
class Farmer
  def initialize
    $options = ARGV.getopts("","loglevel:","wizard")
    @interface = Local
    @interface.start
    Debug.start
    play
    shutdown
  end

  def shutdown
    Debug.stop
    @interface.stop
  end

  def play
    while @interface.running?
      received = @interface.receive
      Debug.raw(received)
      Parser.parse(received)
      @interface.transmit
      sleep(0.01)
    end
  end
end

Farmer.new

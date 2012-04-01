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
    @human_override = true
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
      if @human_override
        @interface.transmit get_human_input
      end
      sleep(0.01)
    end
  end

  def get_human_input
    begin
      return STDIN.read_nonblock(1)
    rescue IO::WaitReadable
      return
    end
  end
end

Farmer.new

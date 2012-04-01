#!/usr/bin/env ruby
require "./local"
require "./debug"
require "./parser"

class Farmer
  def initialize
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
    end
  end
  
end

Farmer.new

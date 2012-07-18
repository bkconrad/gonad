#!/usr/bin/env ruby
require "optparse"
require "./local"
require "./debug"
require "./parser"
require "./ai"

$options = {}
class Farmer
  include AI

  def initialize
    $options = ARGV.getopts("","loglevel:","wizard")
    @interface = Local
    @interface.start
    @human_override = false
    Debug.start
    play
    shutdown
  end

  def shutdown
    Debug.stop
    @interface.stop
  end

  def play
    add_task Move
    while @interface.running?
      # get and log interface output
      received = @interface.receive
      Debug.raw(received)

      # get instructions from the Parser
      parser_instructions = Parser.parse(received)
      dbg("Sending parser instructions:\n'%s'",parser_instructions) if parser_instructions != nil

      human_input = get_human_input
      if @human_override
        @interface.transmit human_input
      else
        @interface.transmit(parser_instructions || next_task.perform)
      end

      # TODO: we should wait for input, not sleep
      sleep(0.01)
    end
  end

  def get_human_input
    begin
      input = STDIN.read_nonblock(1)
    rescue IO::WaitReadable
      return
    end

    # ^[ toggles human input
    if input == "\x1D"
      @human_override = !@human_override
      return nil
    end
    return input
  end
end

Farmer.new

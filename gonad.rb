#!/usr/bin/env ruby
require "pry"
require "./local"
require "./debug"
require "./parser"
require "./ai"
require "./task"
require "./options"

$options = {}
class Gonad
  include AI

  def initialize
    Options.parse
    Debug.start(Options.get "loglevel")
    @interface = Local
    @interface.start wizard: Options.get('wizard')

    @human_override = false

    play
    shutdown
  end

  def shutdown
    Debug.stop
    @interface.stop
  end

  def play
    add_task Task::Explore.new
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
        @interface.transmit(parser_instructions || perform_next_task)
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

    case input 
    # ^] toggles human input
    when "\x1D"
      @human_override = !@human_override
      return nil
    # ` drops to the pry debug prompt
    when '`'
      @interface.stop
      binding.pry
      system 'reset'
      @interface.transmit "\x12"
      @interface.continue
    end
    return input
  end
end

if __FILE__ == $0
  Gonad.new
end

#!/usr/bin/env ruby
require 'pty'

require 'test/unit'
require 'shoulda'

require './vt'

class VTTest < Test::Unit::TestCase
  context "VT" do
    setup do
      system('stty raw -echo')
      @childout, @childin, @childpid = PTY.spawn("util/echo.rb")
      @vt = VT::VTBuffer.new
    end

    should "start a command and parse input" do
      @childin.write "test\n\n"
      Process.wait

      begin
        output = ""
        while true
          output += @childout.getc
        end
      rescue
        @vt.parse(output)
      end

      assert @vt.row(0).match /^test$/
    end

    should 'set cursor position on \e[H' do
      @childout, @childin, @childpid = PTY.spawn("util/echo.rb")
      @childin.write "\e[13;37H\n\n"
      Process.wait

      begin
        output = ""
        while true
          output += @childout.getc
        end
      rescue
        @vt.parse(output)
      end

      # one of the two trailing newlines is appended
      assert @vt.get == [13, 38]
    end

    teardown do
      system('stty -raw echo')
      # expect an exception
      begin
        if Process.getpgid(@childpid)
          puts Process.getpgid(@childpid)
        end
      rescue
        # safely return if one was raised
        next
      end
      # otherwise, raise a real exception
      raise Exception, "Echo process is still alive"
    end
  end
end

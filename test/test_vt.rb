#!/usr/bin/env ruby
require 'pty'

require 'test/unit'
require 'shoulda'

require './vt'

class VTTest < Test::Unit::TestCase
  context "VT" do
    setup do
      @childout, @childin, @childpid = PTY.spawn("util/echo.rb")
    end

    should "start a command and parse input" do
      vt = VT::VTBuffer.new

      @childin.puts "test\n\r"
      Process.wait

      vt.parse(@childout.gets)
      assert vt.row(0).match /^test$/
    end

    teardown do
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

#!/usr/bin/env ruby
require 'pty'
module Local
  
  def self.start
    childio = PTY.spawn("nethack", "rw")
    @childout = childio[0]
    @childin = childio[1]
    @childpid = childio[2]
    @childin.write("y Of    ")
    system "stty cbreak </dev/tty >/dev/tty 2>&1";
    system "stty -echo </dev/tty >/dev/tty 2>&1";
  end
    
  def self.stop
    system "stty -cbreak </dev/tty >/dev/tty 2>&1";
    system "stty echo </dev/tty >/dev/tty 2>&1";
  end

  def self.receive
    received = ""
    while true
      begin
        char = @childout.read_nonblock(1)
      rescue IO::WaitReadable
        return received
      end

      received += char
      putc char
    end
  end

  def self.transmit
    begin
      c = STDIN.read_nonblock(1)
    rescue IO::WaitReadable
      return
    end
    @childin.write c
  end

  def self.running?
    PTY.check(@childpid) == nil
  end

  def self.waiting?
    
  end
end

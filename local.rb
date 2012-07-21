#!/usr/bin/env ruby
require 'pty'

# Interfaces are responsible for gathering some nethack output from a source,
# and delivering the user input to that source if applicable.
#
# This interface assumes nethack is available in the current path

module Local
  
  def self.start args
    if args[:wizard]
      childio = PTY.spawn("sudo -u wizard nethack -D")
    else
      childio = PTY.spawn("nethack")
    end
    @childout = childio[0]
    @childin = childio[1]
    @childpid = childio[2]
    @childin.write("y    Of      ")
    continue
  end
    
  def self.stop
    system "stty -cbreak </dev/tty >/dev/tty 2>&1";
    system "stty echo </dev/tty >/dev/tty 2>&1";
    system "reset"
  end

  def self.continue
    system "stty cbreak </dev/tty >/dev/tty 2>&1";
    system "stty -echo </dev/tty >/dev/tty 2>&1";
  end

  def self.receive
    received = ""
    while true
      begin
        char = @childout.read_nonblock(1)
        received += char
        putc char
      rescue IO::WaitReadable
        return received
      end
    end
    return received
  end

  def self.transmit str
    @childin.write str
  end

  def self.running?
    PTY.check(@childpid) == nil
  end

  def self.waiting?
    
  end
end

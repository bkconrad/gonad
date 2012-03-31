#!/usr/bin/env ruby
require "./local"
interface_module = Local
interface_module.start
while interface_module.running?
  interface_module.receive
  interface_module.transmit
end
interface_module.stop

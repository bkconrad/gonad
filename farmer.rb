#!/usr/bin/env ruby
require "./local"
require "./debug"

interface_module = Local
interface_module.start
Debug.start
while interface_module.running?
  Debug.print(interface_module.receive)
  interface_module.transmit
end
Debug.stop
interface_module.stop

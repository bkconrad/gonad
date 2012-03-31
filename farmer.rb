#!/usr/bin/env ruby
require "./local"
require "./debug"
require "./parser"

interface_module = Local
interface_module.start
Debug.start
while interface_module.running?
  received = interface_module.receive
  Debug.raw(received)
  Parser.parse(received)
  interface_module.transmit
end
Debug.stop
interface_module.stop

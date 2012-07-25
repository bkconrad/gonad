#!/usr/bin/env ruby

# A trivial event bus allowing for lambda functions to be executed on specific
# events. 
module EventBus
  @callbacks = {}

  module_function

  # call callback on event. event should be a symbol, callback should be a
  # lambda, which will ensure that it performs argument checking (thus firing
  # an event with malformed data arguments should raise an error in its
  # handlers). this also changes the behavior of 'return' in side of the block 
  #   # will throw an error, since the lambda checks its arguments
  #   EventBus.on :foo, ->(x) { |x| puts "foo triggered with #{x}" }
  #   EventBus.fire :foo, 'one', 'two'
  def on event, callback
    raise Exception, "Non-lambda event passed" unless callback.lambda?
    @callbacks[event] ||= [] 
    @callbacks[event].push callback
  end

  # triggers all callbacks on event. *data is passed to each callback, with the
  # intention that errors are triggered when arguments don't match up. this is
  # a measure against argument-safety loss inherent in an event bus.
  def fire event, *data
    dbg "firing event '#{event}'"
    (@callbacks[event] || []).each do |callback|
      callback.call *data
    end
  end

  # remove all callbacks from all events
  def clear_callbacks
    @callbacks = {}
  end
end

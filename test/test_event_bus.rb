#!/usr/bin/env ruby
require 'test/unit'
require 'shoulda'

require 'event_bus'

class EventBusTest < Test::Unit::TestCase
  context "EventBus" do
    setup do
    end

    should "accept and trigger a callback" do
      called = false
      EventBus.on :foo, ->(x) { called = x }

      EventBus.fire :foo, true
      assert called
    end

    should "trigger multiple callbacks" do
      called = false
      called2 = false
      EventBus.on :foo, ->(x) { called = x }
      EventBus.on :foo, ->(x) { called2 = x }

      EventBus.fire :foo, true
      assert called
      assert called2
    end

    should "only trigger callbacks for the appropriate event" do
      called = false
      called2 = false
      EventBus.on :foo, ->(x) { called = x }
      EventBus.on :bar, ->(x) { called2 = x }

      EventBus.fire :foo, true
      assert called
      refute called2
    end

    should "throw an error on mismatched arguments" do
      assert_raise ArgumentError do
        EventBus.on :foo, ->(x) { called = x }
        EventBus.fire :foo
      end
    end

    teardown do
      EventBus.clear_callbacks
    end
  end
end

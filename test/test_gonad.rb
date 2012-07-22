#!/usr/bin/env ruby
require 'gonad'
require 'test/unit'
require 'shoulda'
class GonadTest < Test::Unit::TestCase
  context "Gonad" do
    should "run" do
      assert !!Gonad
    end
  end
end

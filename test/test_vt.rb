#!/usr/bin/env ruby
require 'test/unit'
require 'shoulda'

require './vt'

class VTTest < Test::Unit::TestCase

  context "VT" do
    setup do
      @vt = VT::VTBuffer.new
    end

    should "parse input" do
      @vt.parse("test")
      assert @vt.all.match /^test/
    end

    should 'set cursor position on \e[H' do
      @vt.parse "\e[13;37H"
      assert @vt.get == [13, 37]
    end

  end
end

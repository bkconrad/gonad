#!/usr/bin/env ruby
require 'test/unit'
require 'shoulda'

require './vt'

class VTTest < Test::Unit::TestCase

  context 'Virtual Terminal (VT)' do
    setup do
      @vt = VT::VTBuffer.new
    end

    should 'initialize the buffer' do
      assert(@vt.get == [1, 1], 'cursor is at origin')
    end

    should 'parse input' do
      @vt.parse('test')
      assert @vt.all.match /^test/
    end

    should 'set cursor position on \e[H' do
      @vt.parse "\e[13;37H"
      assert @vt.get == [13, 37]
    end

    should 'set sgr commands' do
      @vt.parse "\e[36;1mtest"
      assert @vt.row_glyphs[0][0].color == :cyan
      assert @vt.row_glyphs[0][0].style == :bold
    end

    should 'not change lines on a new line character' do
      @vt.parse "\n"
      assert @vt.get == [1, 2]
    end
  end
end

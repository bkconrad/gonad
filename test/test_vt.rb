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

    should 'reset sgr commands when passed nothing or zero' do
      @vt.parse "\e[36;1mfoo\e[0mbar"
      assert @vt.row_glyphs[0][0].color == :cyan
      assert @vt.row_glyphs[0][0].style == :bold

      assert @vt.row_glyphs[0][4].color == :none
      assert @vt.row_glyphs[0][4].style == :normal
    end

    should 'not reset sgr when passed \e[m without parameters' do
      @vt.parse "\e[36;1mfoo\e[mbar"
      assert @vt.row_glyphs[0][0].color == :cyan
      assert @vt.row_glyphs[0][0].style == :bold

      assert @vt.row_glyphs[0][4].color == :cyan
      assert @vt.row_glyphs[0][4].style == :bold
    end

    should 'not change lines on a new line character' do
      @vt.parse "\n"
      assert @vt.get == [1, 2]
    end

    should 'return a specific line of text' do
      @vt.parse "foo\e[2;1Hbar"
      assert(@vt.row(1).match(/^bar/))
    end

    should 'return all text concatenated as a string without ANSI codes' do
      @vt.parse "foo\e[2;1Hbar"
      assert_equal VT::VTBuffer::TERMWIDTH * VT::VTBuffer::TERMHEIGHT,
        @vt.all.length

      refute @vt.all.match(/\e/) 
    end
  end
end

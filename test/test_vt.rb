#!/usr/bin/env ruby
require 'test/unit'
require 'shoulda'

require './vt'

class VT102Test < Test::Unit::TestCase

  context 'Virtual Terminal (VT)' do
    setup do
      @stream = VT102::Stream.new
      @screen = VT102::Screen.new
      @stream.attach @screen
    end

    should "parse and print text" do
      @stream.process 'test'
      assert @screen.to_s.match /^test/
    end

    should 'perform a line feed on \n' do
      @stream.process "foo\nbar"
      assert_equal [2, 7], @screen.position
    end

    should 'backspace to the beginning of the line' do
      @stream.process "foo\n\b\b\b\b"
      assert_equal [2, 1], @screen.position
    end

    should 'return cursor to first column' do
      @stream.process "test\r"
      assert_equal [1, 1], @screen.position
    end

    should 'move cursor up' do
      @stream.process "foo\n\rbar\e[A"
      assert_equal [1, 4], @screen.position
    end

    should 'move cursor down' do
      @stream.process "foo\n\rbar\e[B"
      assert_equal [3, 4], @screen.position
    end

    should 'move cursor forward' do
      @stream.process "foo\n\rbar\e[C"
      assert_equal [2, 5], @screen.position
    end

    should 'move cursor backward' do
      @stream.process "foo\n\rbar\e[D"
      assert_equal [2, 3], @screen.position
    end

    should 'move to a specified position' do
      @stream.process "\e[13;37H"
      assert_equal [13, 37], @screen.position
    end

    should 'clear to the end of the line' do
      @stream.process "foo\n\rbar\r\e[K"
      assert @screen.to_s.match /foo/
      refute @screen.to_s.match /bar/
    end

    should 'clear to the beginning of the line' do
      @stream.process "foo\n\rbar\e[1K"
      assert @screen.to_s.match /foo/
      refute @screen.to_s.match /bar/
    end

    should 'clear to the whole line' do
      @stream.process "---bar\rfoo\e[2K"
      refute @screen.to_s.match /foo/
      refute @screen.to_s.match /bar/
    end

    should 'clear from the cursor down' do
      # put one X on a line followed by one Y on the beginning of each line
      # after that
      @stream.process "X" + "\n\rY"*(@screen.rows - 1)
      # move to the second line
      @stream.process "\e[2;1H"
      # clear from the cursor to the end of the display
      @stream.process "\e[J"
      refute @screen.to_s.match /Y/
    end

    should 'clear from the cursor up' do
      # put one X on a line preceeded by one Y on the beginning of each line
      # after that
      @stream.process "Y\n\r"*(@screen.rows - 1) + "X"
      # move to the second to last line
      @stream.process "\e[#{@screen.rows - 1};1H"
      # clear from the cursor to the beginning of the display
      @stream.process "\e[1J"
      refute @screen.to_s.match /Y/
    end

    should 'clear the whole display' do
      # put one X on the beginning of each line
      @stream.process "X" + "\n\rX"*(@screen.rows - 1)
      @stream.process "\e[2J"
      refute @screen.to_s.match /X/
    end

    should 'delete, shift, and append characters' do
      @stream.process "foo12345bar"
      @stream.process "\e[1;4H"
      @stream.process "\e[5P"
      assert @screen.to_s.match /foobar/
      assert_equal @screen.cols, @screen.contents[@screen.row - 1].length
    end

    should 'set color and style' do
      @stream.process "\e[36;1m"
      @stream.process "foo"
      assert_equal :cyan, @screen.contents[0][0].color
      assert_equal :bold, @screen.contents[0][0].style
    end

    should 'reset color and style' do
      @stream.process "\e[36;1m"
      @stream.process "foo"
      @stream.process "\e[m"
      @stream.process "bar"
      assert_equal :none, @screen.contents[0][3].color
      assert_equal :normal, @screen.contents[0][3].style
    end
  end
end

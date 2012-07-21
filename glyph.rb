#!/usr/bin/env ruby
class Glyph
  COLOR = {
    none: nil
  }
  attr_accessor :char, :color

  def initialize char = ' ', color = COLOR[:none]
    @color = color
    @char = char
  end

  def <=> arg
    if arg.kind_of? String
      return @char <=> arg
    end
  end

  def to_s
    @char
  end

  # return a string with ansi escape to print this glyph with its attributes
  def to_ansi
    "\e[#{@color}m#{@char}"
  end
end

#!/usr/bin/env ruby
class Glyph
  COLOR = {
    none: 39,
    black: 30,
    red: 31,
    green: 32,
    brown: 33,
    blue: 34,
    magenta: 35,
    cyan: 36,
    gray: 37
  }

  STYLE = {
    none: 22,
    invert: 7,
    bold: 1,
    normal: 22
  }
  attr_accessor :char, :color, :style

  def initialize char = ' ', color = COLOR[:none], style = STYLE[:none]
    @color = color
    @char = char
    @style = style
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
    return "\e[#{@style};#{@color}m#{@char}"
  end
end

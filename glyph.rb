#!/usr/bin/env ruby

require './glyph_map'

class Glyph

  include GlyphMap

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

  ANSI_TO_ATTRIBUTE = {
    39 => :none,
    30 => :black,
    31 => :red,
    32 => :green,
    33 => :brown,
    34 => :blue,
    35 => :magenta,
    36 => :cyan,
    37 => :gray,
    7 => :invert,
    1 => :bold,
    22 => :normal
  }

  STYLE = {
    invert: 7,
    bold: 1,
    normal: 22
  }
  attr_accessor :char
  attr_reader :color, :style

  def color= arg
    if !arg.kind_of? Symbol
      @color = ANSI_TO_ATTRIBUTE[arg.to_i]
    else
      @color = arg
    end

    if !@color.kind_of? Symbol
      raise Exception, "\nnon-symbol color after color=: '#{@color}'\nWas passed '#{arg}'"
    end
  end

  def style= arg
    if !arg.kind_of? Symbol
      @style = ANSI_TO_ATTRIBUTE[arg.to_i]
    else
      @style = arg
    end

    if !@style.kind_of? Symbol
      raise Exception, "\nnon-symbol style after style=: '#{@style}'\nWas passed '#{arg}'"
    end
  end

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
    return "\e[#{@style};#{COLOR[@color]}m#{@char}"
  end
end

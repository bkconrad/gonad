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
end

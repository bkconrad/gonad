#!/usr/bin/env ruby
module GlyphMap
  GLYPHMAP = {
    # [ char, color, style ]
    ['+', :brown, :normal ] => :door,
    ['-', :brown, :normal ] => :door,
    ['|', :brown, :normal ] => :door,
    ['+', :none, :normal ]  => :wall,
    ['-', :none, :normal ]  => :wall,
    ['|', :none, :normal ]  => :wall,
    [' ', :none, :normal ]  => :rock,
    ['.', :none, :normal ]  => :floor,
    ['>', :none, :normal ]  => :down_stairs,
    ['<', :none, :normal ]  => :up_stairs,
    ['#', :none, :normal ]  => :floor
  }

  # get the type of thing represented by this glyph
  def to_thing
    return GLYPHMAP[[char, color, style]] || :unknown
  end
end

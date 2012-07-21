#!/usr/bin/env ruby
class Map < Array
  ROWS = 22
  COLS = 80

  def initialize
    fill 0...ROWS do |index|
      [].fill 0...COLS, nil
    end
  end

  def dump
    result = ""
    each do |row|
      row.each do |element|
        case element
        when :floor
          result += "."
        when :wall
          result += "+"
        else
          result += " "
        end
      end
      result += "\n"
    end
    result
  end
end

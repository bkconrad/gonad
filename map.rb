#!/usr/bin/env ruby
class Map < Array
  ROWS = 22
  COLS = 80

  def initialize
    fill 0...ROWS do |index|
      [].fill 0...COLS, nil
    end
  end

  def overlay arr
    result = ""
    each_index do |i|
      self[i].each_index do |j|
        overlay_glyph = nil
        arr.each do |entry|
          if entry[0] == i + 1 && entry[1] == j + 1
            overlay_glyph = [9, entry[2].to_i].min.to_s
          end
        end

        if overlay_glyph != nil
          result += overlay_glyph
          next
        end

        case self[i][j]
        when :floor
          result += "."
        when :wall
          result += "+"
        when :door
          result += "%"
        when :down_stairs
          result += ">"
        when :up_stairs
          result += "<"
        else
          result += " "
        end
      end
      result += "\n"
    end
    result
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
        when :door
          result += "%"
        when :down_stairs
          result += ">"
        when :up_stairs
          result += "<"
        else
          result += " "
        end
      end
      result += "\n"
    end
    result
  end

  # returns the entity at row, col (1-indexed as always)

  def get row, col
    self[row - 1][col - 1]
  end

  # returns an array of adjacent tiles which exist on the map

  def get_adjacent row, col
    result = []

    # tiles above
    if row > 1
      result.push [row - 1, col]
      if col > 1
        result.push [row - 1, col - 1]
      end

      if col < COLS
        result.push [row - 1, col + 1]
      end
    end

    # tiles on this row
    if col > 1
      result.push [row, col - 1]
    end

    if col < COLS
      result.push [row, col + 1]
    end

    # tiles on the row below
    if row < ROWS
      result.push [row + 1, col]
      if col > 1
        result.push [row + 1, col - 1]
      end

      if col < COLS
        result.push [row + 1, col + 1]
      end
    end

    result
  end
end

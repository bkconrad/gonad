#!/usr/bin/env ruby
class Map < Array
  ROWS = 20
  COLS = 80

  def initialize
    fill ([].fill nil, 0...COLS), 0...ROWS
  end
end

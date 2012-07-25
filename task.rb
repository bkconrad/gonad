#!/usr/bin/env ruby
require './debug'

class Task

  # returns the character sequence needed to perform the next step of the
  # task, or nil if the task is complete
  def perform
  end

  # returns whether the task has completed
  def complete?
    false
  end

  class Direction
    DIRECTIONS = [%w(y k u),
                  %w(h . l),
                  %w(b j n)]

    def self.random
      return DIRECTIONS[rand(3)][rand(3)]
    end

    def initialize *args
      if args.length == 2
        @direction = [args[0], args[1]]        
        @key = DIRECTIONS[args[0]+1][args[1]+1]
      end
    end

    def to_s
      return @key
    end

    def to_a
      return @direction
    end
  end

  class MoveTo < Task
    attr_accessor :target, :main_list, :path, :keys

    # select tile costs in array which are adjacent to the given point

    def adjacent_tiles row, col, arr
      arr.select do |tile|
        next (row - tile[0]).abs <= 1 && (col - tile[1]).abs <= 1
      end
    end

    # prune entries in arr which are less or equally efficient to an entry in
    # @main_list

    def path_filter arr
      @main_list.each do |bar|
        arr.select! do |candidate|
          if [bar[0], bar[1]] == [candidate[0], candidate[1]] && bar[2] <= candidate[2] && !(bar.equal? candidate)
            next false
          end
          next true
        end
      end
    end

    def tile_path_to_keys arr
      start = arr[0]
      result = ""
      arr[1..-1].each do |tile|
        delta = [ tile[0] - start[0], tile[1] - start[1] ]
        result += Direction::DIRECTIONS[delta[0] + 1][delta[1] + 1]
        start = tile
      end
      result
    end

    def initialize row, col
      @target = [row, col]
      @origin = Knowledge.player.position

      dbg "Find path from #{@origin} to #{@target}"

      # find path using A*
      @main_list = []
      add_tile @target

      done = false
      @main_list.each do |master_tile|
        if done
          break
        end

        @tmp_list = Knowledge.dungeon_map.get_adjacent master_tile[0], master_tile[1]

        # only consider floors
        @tmp_list.select! do |pos|
          next [:floor, :door, :down_stairs, :up_stairs].include?(Knowledge.dungeon_map.get pos[0], pos[1])
        end

        # initialize starting tile costs
        @tmp_list.each { |tile| tile[2] = master_tile[2] + 1 }

        # drop any tiles with same position and higher cost from main_list
        path_filter @main_list

        # drop any tiles with same position and higher cost from tmp_list
        path_filter @tmp_list

        # add all points in tmp_list to main_list
        # stop if we hit the starting point
        @tmp_list.each do |tile|
          if @origin[0] == tile[0] && @origin[1] == tile[1]
            done = true
          end
          @main_list.push tile
        end
      end

      # use the data from the A* search to construct shortest path.
      # the first point is the starting point.
      pos = @origin
      @path = [@origin]
      while pos != @target
        candidates = adjacent_tiles pos[0], pos[1], @main_list
        best = candidates[0]

        # no candidates means no path available
        return nil unless best

        for tile in candidates
          if tile[2] < best[2]
            best = tile
          end
        end
        pos = [best[0], best[1]]
        @path.push pos
      end

      @keys = tile_path_to_keys @path
    end

    def perform
      result = @keys[0]
      @keys = @keys[1..-1]
      dbg "use '#{result}' to move next"
      result
    end

    def complete?
      if @keys.length <= 0
        return true
      end
    end

    private

    def add_tile position, cost = 0
      @main_list.push [*position, cost]
    end
  end

  class Explore < Task
    def perform
      if Knowledge.down_stairs == nil
        # look for the stairs
        return Direction.random
      elsif Knowledge.player.position == Knowledge.down_stairs
        return ">"
      else
        AI.add_task MoveTo.new(*Knowledge.down_stairs)
        return nil
      end
    end
  end

  class Move < Task
    attr_accessor :direction
    def perform
      super
      Direction.random
    end
  end
end

module AI
  @@tasks = []
  @@parameters = []
  class Direction
    DIRECTIONS = [%w{y k u},
                  %w{h . l},
                  %w{b j n}]

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

  class Task
    # returns the character sequence needed to perform the next step of the task  
    def self.perform
    end
  end

  class Move < Task
    attr_accessor :direction
    def self.perform
      super
      Direction.random
    end
  end

  def next_task
    return @@tasks[@@tasks.length-1]
  end

  def add_task task
    @@tasks.push(task)
  end
end

require "./debug"
module Parser
  class CursorStatus
    attr_accessor :row, :col, :fg, :bg
    def to_s
      "%i, %i" % [@row, @col]
    end

    def initialize row=0, col=0
      set row, col
    end

    def set *args
      if args[0].kind_of? Array
        row = args[0][0]
        col = args[0][1]
      else
        row = args[0]
        col = args[1]
      end
      if row == ""
        row = 1
      end
      if col == ""
        col = 1
      end

      @row = row.to_i
      @col = col.to_i
    end

    def add *args
      if args[0].kind_of? Array
        row = args[0][0]
        col = args[0][1]
      else
        row = args[0]
        col = args[1]
      end
      @row += row.to_i
      @col += col.to_i
    end

    def increment
      @col += 1
    end

    def decrement
      @col -= 1
    end
  end

  ESC="\e"
  CODES={"A" => {add: [-1, 0]},
         "B" => {add: [1, 0]},
         "C" => {add: [0, 1]},
         "D" => {add: [0, -1]},
         "m" => nil,
         "h" => nil,
         "J" => nil,
         "H" => {set: /\e\[(\d*);?(\d*)H/},
         "K" => nil}

  LINEHANDLERS={1 => :parse_topline,
                23 => :parse_attribute_line,
                24 => :parse_status_line}


  def self.parse str
    @pos = CursorStatus.new
    i = 0
    while i < str.length
      while str[i] == ESC
        # parse_escape returns the number of characters handled
        i += parse_escape str, i
        i += 1
      end

# grab a chunk
      j = i
      while str[j] != ESC && j < str.length
        j += 1
      end
      j -= 1

# send chunk through the proper handler
      if LINEHANDLERS.include? @pos.row
        self.send(LINEHANDLERS[@pos.row], str[i..j])
        i = j
      end

      @pos.increment
      i += 1
    end
  end

  def self.parse_escape str, i
    j = i + 1
    while !CODES.include?(str[j]) && j < str.length
      if str[j] == ESC
        Debug.log("unexpected escape in %s", str[i..j])
        exit
      end
      j += 1
    end

    # Debug.log("Found escape code %s", str[i..j])

    action = CODES[str[j]]
    if action != nil
      method = action.keys[0]
      method_args = action[method]

      if method_args.kind_of?(Regexp)
        matches = method_args.match(str[i..j])
        method_args = matches[1..2]
      end

      @pos.send(method, method_args)
      # Debug.log("Set cursor position to %s", @pos)
    end

    j - i
  end

  def self.parse_topline str
    Debug.log("Found message %s", str)
  end

  def self.parse_attribute_line str
    Debug.log("Found attribute %s", str)
  end

  def self.parse_status_line str
    Debug.log("Found status %s", str)
  end
end

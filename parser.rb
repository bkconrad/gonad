require "./debug"
module Parser
  attr_accessor :row, :col, :fg, :bg
  @row = 1
  @col = 1
  def self.position
    "%i, %i" % [@row, @col]
  end

  def self.initialize row=0, col=0
    set row, col
  end

  def self.set *args
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

    @row = row.to_i unless row == -1
    @col = col.to_i unless col == -1
  end

  def self.add *args
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

  def self.clear_line *args
    Debug.log("clearing line %s", args.join)
    if @col == 23
    end
    #@col = 1
  end

  def self.increment
    @col += 1
  end

  def self.decrement
    @col -= 1
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
      if LINEHANDLERS.include? @row
        self.send(LINEHANDLERS[@row], str[i..j])
        i = j
      end

      if str[i] == "\r"
        add 1, 0
        set -1, 1
      end

      increment
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
        method_args = matches.to_a[1..-1]
      end

      self.send(method, method_args)
      Debug.log("Set cursor position to %s", position)
    end

    j - i
  end

  def self.parse_topline str
    Debug.log("Found message %s", str)
  end

  def self.parse_attribute_line str
    i = @col - 1
    str.each_char do |c|
      return if c == "\e"
      @attributes[i] = c unless c == "\r"
      i += 1
    end
    #@attributes = [@attributes[-1..i].to_s, str, @attributes[i + str.length..@attributes.length-1]].join
    Debug.log("Found attribute %s", @attributes)
  end

  def self.parse_status_line str
    Debug.log("Found status %s", str)
  end
end

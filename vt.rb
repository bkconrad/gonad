require "./debug"
module VT
  attr_accessor :row, :col, :fg, :bg

  ESC="\e"
  CODES={"A" => {add: [-1, 0]},
         "B" => {add: [1, 0]},
         "C" => {add: [0, 1]},
         "D" => {add: [0, -1]},
         "m" => nil,
         "h" => nil,
         "J" => {clear_data: /\e\[(\d)*J/},
         "H" => {set: /\e\[(\d*);?(\d*)H/},
         "K" => {clear_line: /\e\[(\d)*K/}
  }

  TERMWIDTH=80
  TERMHEIGHT=24

  @line_contents = {}
  for i in 0..TERMHEIGHT
    @line_contents[i] = " " * TERMWIDTH
  end

  @row = 1
  @col = 1

  def self.position
    "%i, %i" % [@row, @col]
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

  def self.parse_escape str
    unless str[0] == ESC
      extra "parse_escape called on string not starting with ESC\n%s", str
      return str
    end

    i = 1
    while !CODES.include?(str[i])
      if str[i] == ESC
        err("unexpected escape in %s", str[0..i])
      end
      if i >= str.length
        err("Unclosed escape sequence\n%s", str)
      end
      i += 1
    end
    extra("Found escape code %s", str[0..i])

    action = CODES[str[i]]
    if action != nil
      method = action.keys[0]
      method_args = action[method]

      if method_args.kind_of?(Regexp)
        matches = method_args.match(str[0..i])
        method_args = matches.to_a[1..-1]
      end

      self.send(method, method_args)
      extra("Set cursor position to %s", position)
    end

    return str[i+1..-1]
  end

  def self.parse_text str
    return "" if str == nil || str.length < 1 
    i = 0
    while str[i] != ESC && i < str.length
      write_char str[i]
      i += 1
    end
    extra("Write to line\n%s", str[0...i].inspect)

    return str[i..-1]
  end

  def self.clear_data *args
    extra("clearing data with %s", args)
    for i in 0...TERMHEIGHT
      @line_contents[i] = " " * TERMWIDTH
    end
  end

  def self.clear_line *args
    extra("clearing line " + @row.to_s + " with %s", args.join)
    for i in @col-1...TERMWIDTH
      @line_contents[@row-1][i] = " "
    end
  end

  def self.increment n=1
    @col += n.to_i
    if @col >= TERMWIDTH
      @col = 1
      @row += 1
    end
  end

  def self.decrement
    @col -= 1
  end

  def self.parse str
    extra("BEGIN PARSE\n%s",str.inspect)
    while str.length > 0
      str = parse_escape str
      extra("After parse_escape\n%s", str.inspect)
      str = parse_text str
      extra("After parse_text\n%s", str.inspect)
    end
    term dump_vt
    extra("END PARSE FRAME\n")
  end

  def self.write_char char
    unless (1..TERMHEIGHT).cover?(@row) && (1..TERMWIDTH).cover?(@col)
      dbg("Position %s,%s out of range", @row, @col)
      return
    end

    if char == "\b"
      decrement
    elsif char != "\r"
      @line_contents[@row-1][@col-1] = char
      increment
    end
  end

  def self.get_rows
    @line_contents
  end

  def self.dump_vt
    # clear screen
    str = "\e[H\e[2J\e[H"
    for i,line in @line_contents
      str += "\e[" + (i+1).to_s + ";1H"
      line.each_char do |c|
        if c == "\e"
          err("Escape in VT contents on line %s", line)
        end
        str += c
      end
    end
    str += "\e[" + @row.to_s + ";" + @col.to_s + "H"
    str
  end
end

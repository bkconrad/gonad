require "./glyph"
require "./debug"

# VT takes nethack output from an Interface and produces a 2D array of Glyph s
# and allows the Parser to query it using several utility functions

module VT
  
  # a clearable buffer with individual cursor and glyph state tracking
  class VTBuffer
    ESC="\e"
    CODES={"A" => {add: [-1, 0]},
           "B" => {add: [1, 0]},
           "C" => {add: [0, 1]},
           "D" => {add: [0, -1]},
           "m" => {set_sgr: /\e\[(\d*);?(\d*)m/},
           "h" => nil,
           "J" => {clear_data: /\e\[(\d)*J/},
           "H" => {set: /\e\[(\d*);?(\d*)H/},
           "K" => {clear_line: /\e\[(\d)*K/}
    }

    TERMWIDTH=80
    TERMHEIGHT=24

    def initialize
      @line_contents = {}
      for i in 0..TERMHEIGHT
        @line_contents[i] = [].fill Glyph.new, 0...TERMWIDTH
      end

      @row = 1
      @col = 1
    end

    def position
      "%i, %i" % [@row, @col]
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

      @row = row.to_i unless row == -1
      @col = col.to_i unless col == -1
    end

    # sets the current SGR (Select Graphic Rendition) properties such as color,
    # bold/normal, foreground color, etc

    def set_sgr args
      if args === []
        extra "resetting style and color"
        @style = Glyph::STYLE[:normal]
        @fg = Glyph::COLOR[:default]
      end
      for arg in args
        if arg === ''
          next
        end

        if arg.to_i === 0
          extra "resetting style and color"
          @style = Glyph::STYLE[:normal]
          @fg = Glyph::COLOR[:default]
        elsif (Glyph::STYLE[:bold]..Glyph::STYLE[:normal]).cover? arg.to_i
          extra "setting style to #{arg}"
          @style = arg
        else
          extra "setting color to #{arg}"
          @fg = arg
        end
      end
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

    def parse_escape str
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

    def parse_text str
      return "" if str == nil || str.length < 1 
      i = 0
      while str[i] != ESC && i < str.length
        write_char str[i]
        i += 1
      end
      extra("Write to line\n%s", str[0...i].inspect)

      # TODO: check that this does what it's meant to...
      return str[i..-1]
    end

    def clear_data *args
      extra("clearing data with %s", args)
      for i in 0...TERMHEIGHT
        @line_contents[i].each_index do |j|
          @line_contents[i][j] = Glyph.new
        end
      end
    end

    def clear_line *args
      extra("clearing line " + @row.to_s + " with %s", args.join)
      for i in (@col-1)...TERMWIDTH
        @line_contents[@row-1][i] = Glyph.new
      end
    end

    def increment n=1
      @col += n.to_i
      if @col >= TERMWIDTH
        @col = 1
        @row += 1
      end
    end

    def decrement
      @col -= 1
    end

    def parse str
      if str.length > 0
        extra("BEGIN PARSE\n%s",str.inspect)
        while str.length > 0
          str = parse_escape str
          extra("After parse_escape\n%s", str.inspect)
          str = parse_text str
          extra("After parse_text\n%s", str.inspect)
        end
        extra("END PARSE FRAME\n")
      end
    end

    def write_char char
      unless (1..TERMHEIGHT).cover?(@row) && (1..TERMWIDTH).cover?(@col)
        err("Position %s,%s out of range", @row, @col)
        return
      end

      if char == "\b"
        decrement
      elsif char != "\r"
        @line_contents[@row-1][@col-1].char = char
        @line_contents[@row-1][@col-1].color = @fg
        @line_contents[@row-1][@col-1].style = @style
        increment
      end
    end

    def row_glyphs
      @line_contents
    end

    def dump
      # clear screen
      str = "\e[H\e[2J\e[H"
      for i,line in @line_contents
        str += "\e[" + (i+1).to_s + ";1H"
        line.each do |glyph|
          str += glyph.to_ansi
        end
      end
      str += "\e[" + @row.to_s + ";" + @col.to_s + "H"
      str
    end

    # returns the full contents of the VTBuffer as a string, or nil if it is
    # empty

    def all
      if @line_contents != nil
        result = @line_contents.map do |index, line|
          next line.join
        end
        return result.join
      end
    end

    # returns the contents of the 0-indexed row number as a string

    def row row_index
      return @line_contents[row_index].join if @line_contents != nil
    end
  end
end

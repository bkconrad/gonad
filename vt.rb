require "./glyph"
require "./debug"

# VT takes nethack output from an Interface and produces a 2D array of Glyph s
# and allows the Parser to query it using several utility functions

module VT
  
  # a clearable buffer with individual cursor and glyph state tracking
  class VTBuffer
    ESC="\e"

    # a map of ANSI escape codes to the methods that implement them. values may
    # be either a symbol, a hash, or nil. if a symbol is found, it is taken as
    # the method name, if a hash is found, the first (only) key is the method
    # name, and the value is an array of arguments to be passed. if nil is
    # found, the escape code is ignored

    CODES={"A" => {add: [-1, 0]},
           "B" => {add: [1, 0]},
           "C" => {add: [0, 1]},
           "D" => {add: [0, -1]},
           "m" => :set_sgr,
           "h" => nil,
           "J" => :clear_data,
           "H" => :set,
           "K" => :clear_line
    }

    # regex to match any recognized escape code character
    ESCAPECODEREGEX = Regexp.new("[#{CODES.keys.join}]")

    # regex to match parameters inside of an escape
    ESCAPEPARAMETERREGEX = /(\d+);?/

    # regex to match an escape code which begins the test string
    # matches the code specifier
    ESCAPEREGEX = /^\x1B\[[\d;]*([\w])/

    TERMWIDTH=80
    TERMHEIGHT=24

    def initialize
      @line_contents = []
      for i in 0..TERMHEIGHT
        @line_contents[i] = [].fill(0, TERMWIDTH) { Glyph.new }
      end

      @row = 1
      @col = 1
      @fg = Glyph::COLOR[:none]
      @style = Glyph::STYLE[:normal]
    end

    def position
      "%i, %i" % [@row, @col]
    end

    def set row = 1, col = 1, extra = nil
      extra("set received #{row},#{col},#{extra}")
      if row == ""
        row = 1
      end
      if col == ""
        col = 1
      end

      @row = row.to_i unless row == -1
      @col = col.to_i unless col == -1
    end

    # sets the current SGR (Select Graphic Rendition) properties such as
    # background color, bold/normal, foreground color, etc

    def set_sgr *args
      if args === []
        extra "resetting style and color"
        @style = Glyph::STYLE[:normal]
        @fg = Glyph::COLOR[:none]
      end
      for arg in args
        if arg === ''
          next
        end

        if arg.to_i === 0
          extra "resetting style and color"
          @style = Glyph::STYLE[:normal]
          @fg = Glyph::COLOR[:none]
        elsif (Glyph::STYLE[:bold]..Glyph::STYLE[:normal]).cover? arg.to_i
          extra "setting style to #{arg}"
          @style = arg
        else
          extra "setting color to #{arg}"
          @fg = arg
        end
      end
    end

    def add row, col
      @row += row.to_i
      @col += col.to_i
    end

    def parse_escape str

      escape_sequence = ESCAPEREGEX.match(str)

      unless escape_sequence
        extra "parse_escape called on string not starting with ESC\n%s", str
        return str
      end

      action = escape_sequence.captures[0]
      method_specifier = CODES[action]
      method_args = nil

      case method_specifier
      when Symbol
        method = method_specifier
      when Hash
        method = method_specifier.keys[0]
        method_args = method_specifier.values[0]
      when nil
        # TODO: handle the do-nothing case
      end

      # if nil, we search for the parameters using the regex and pass them as an
      # array
      if method_args === nil
        method_args = []

        # start after the "\e["
        i = 2
        while parameter_match = escape_sequence.to_s[i..-1].match(ESCAPEPARAMETERREGEX)
          method_args.push parameter_match.captures[0]
          i += parameter_match.captures[0].length
        end
      end

      self.send(method, *method_args)
      extra("Set cursor position to %s", position)

      return str[(escape_sequence.to_s.length)..-1]
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
      @line_contents.each_index do |i|
        str += "\e[" + (i+1).to_s + ";1H"
        @line_contents[i].each do |glyph|
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
        result = @line_contents.map do |line|
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

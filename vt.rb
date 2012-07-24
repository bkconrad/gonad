require "./glyph"
require "./debug"

require './escape'

# VT102 takes nethack output from an Interface and produces a 2D array of Glyph
# s and allows the Parser to query it using several utility functions

module VT102
  
  BASIC = {
    BS => :backspace,
    HT => :tab,
    LF => :linefeed,
    VT => :linefeed,
    FF => :linefeed,
    CR => :carriage_return,
    SI => :shift_in,
    SO => :shift_out
  }

  ESCAPE = {
    IND   => :index,
    RI    => :reverse_index,
    NEL   => :linefeed,
    DECSC => :store_cursor,
    DECRC => :restore_cursor,
    RLF   => :reverse_linefeed
  }

  SEQUENCE = {
    CUU     => :cursor_up,
    CUD     => :cursor_down,
    CUF     => :cursor_right,
    CUB     => :cursor_left,
    CUP     => :cursor_move,
    HVP     => :cursor_move,
    EL      => :erase_in_line,
    ED      => :erase_in_display,
    DCH     => :delete_characters,
    IL      => :insert_lines,
    DL      => :delete_lines,
    SGR     => :select_graphic_rendition,
    DECSTBM => :set_margins,
    IRMI    => :set_insert,
    IRMR    => :set_replace
  }

  class Screen
    attr_accessor :contents, :row, :col, :rows, :cols
    def initialize rows = 24, cols = 80
      @contents = []

      @rows = rows
      @cols = cols
      @row = 1
      @col = 1
      @fg = Glyph::COLOR[:none]
      @style = Glyph::STYLE[:normal]
      @tab_stops = []

      for i in 0...@rows
        @contents[i] = [].fill(0, @cols) { Glyph.new }
      end
    end

    # returns the glyphs comprising the given row number, and throws an error
    # if row number is not in the range of the current screen

    def row_glyphs row_num
      unless (1..@rows).cover? row_num
        raise Exception "Row #{row_num} is out of range (max #{@rows})"
      end
      @contents[row_num - 1]
    end

    # returns the contents of the VT as a string without line breaks

    def all
      @contents.flatten.join
    end

    def position
      [ @row, @col ]
    end

    def print char
      unless (1..@rows).cover?(@row) && (1..@cols).cover?(@col)
        raise Exception, "#{@row}, #{@col} is out of range"
      end

      # translate from terminal coords to array coords
      @contents[@row - 1][@col - 1].char = char
      @contents[@row - 1][@col - 1].color = @fg
      @contents[@row - 1][@col - 1].style = @style

      @col += 1
      if @col > @cols
        linefeed
      end
    end

    def linefeed
      if @row + 1 > @rows
        @contents.shift
        @contents.push([].fill(0...@cols) { Glyph.new })
      else
        @row += 1
      end
    end

    def backspace
      @col = [1, @col - 1].max
    end

    def tab
      @col = next_tab
    end

    # return next tab stop or the right-most column's column mumber

    def next_tab
      @tab_stops.sort.each do |stop|
        if @col < stop
          return stop
        end
      end

      return @cols
    end

    def carriage_return
      @col = 1
    end

    # TODO: G0 character set
    def shift_in
    end

    # TODO: G1 character set
    def shift_out
    end

    # sequence handlers

    def cursor_up
      @row = [1, @row - 1].max
    end 

    def cursor_down
      @row = [@rows, @row + 1].min
    end 

    def cursor_left
      @col = [1, @col - 1].max
    end 

    def cursor_right
      @col = [@cols, @col + 1].min
    end 

    def cursor_move row = 1, col = 1
      @row = row
      @col = col
    end

    def erase_in_line type = 0
      case type.to_i
      when 0
        # cursor to end of line, including cursor
        @contents[@row - 1].fill(@col - 1) { Glyph.new }
      when 1
        # beginning of line to cursor, including cursor
        @contents[@row - 1].fill(0...@col) { Glyph.new }
      when 2
        @contents[@row - 1].fill(0...@cols) { Glyph.new }
      end
    end

    def erase_in_display type = 0
      case type.to_i
      when 0
        # cursor to end of display, including cursor
        # clear current line
        @contents[@row - 1].fill(@col - 1) { Glyph.new }
        # clear succeeding lines
        for i in @row...@rows
          @contents[i].fill(0...@cols) { Glyph.new }
        end
      when 1
        # beginning of display to cursor, including cursor
        # clear current line
        @contents[@row - 1].fill(0...@col) { Glyph.new }
        # clear succeeding lines
        for i in 0...@row
          @contents[i].fill(0...@cols) { Glyph.new }
        end
      when 2
        clear_data
      end
    end

    def delete_characters n = 1
      n.times do 
        @contents[@row - 1].slice! @col - 1
        @contents[@row - 1].push Glyph.new
      end
    end

    # sets the current SGR (Select Graphic Rendition) properties such as
    # background color, bold/normal, foreground color, etc

    def select_graphic_rendition *args
      if args === []
        extra "resetting style and color"
        @style = Glyph::STYLE[:normal]
        @fg = Glyph::COLOR[:none]
      end
      for arg in args
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

    def clear_data *args
      extra("clearing data with %s", args)
      for i in 0...@rows
        @contents[i].fill 0...@cols do Glyph.new end
      end
    end

    def to_s
      result = ""
      @contents.each { |row| result += row.join + "\n"}
      result
    end
  end

  # State machine to parse text and maintain a terminal state based on the ANSI
  # control codes found
  class Stream
    def initialize
      @listeners = []
      @state = :stream
      @parameters = []
      @current_parameter = ""
    end

    # process a string as terminal output

    def process str
      str.each_char do |char|
        # route each character to its state handler
        send(@state, char)
      end
    end

    # attach a screen to this stream

    def attach listener
      @listeners.push listener
    end

    private

    def notify method, *args
      @listeners.each do |listener|
        listener.send method, *args
      end
    end

    # stream mode handler

    def stream char
      if BASIC[char] != nil
        notify BASIC[char]
      elsif char === ESC
        @state = :escape
      else BASIC[char] == nil
        notify :print, char
      end
    end

    # escape mode handler

    def escape char
      case char
      when '['
        @state = :escape_parameters
      end
    end

    # escape parameter mode handler

    def escape_parameters char
      /[^0-9;?]/.match char
      case char
      when $&
        # if the character is not a parameter or separator, it must be a
        # sequence delimiter

        unless @current_parameter == ""
          @parameters.push @current_parameter.to_i
        end

        notify SEQUENCE[char], *@parameters

        @parameters = []
        @current_parameter = ""
        @state = :stream
      when ';'
        @parameters.push @current_parameter.to_i
        @current_parameter = ""
      when '?'
        @state = :mode
      else
        @current_parameter += char
      end
    end

    def mode char
      if ['l', 'h'].include? char
        @state = :stream
      end
    end

    def position
      "%i, %i" % [@row, @col]
    end

    # get position as an array
    def get
      return [@row, @col]
    end

    def clear_line *args
      extra("clearing line " + @row.to_s + " with %s", args.join)
      for i in (@col-1)...TERMWIDTH
        @contents[@row-1][i] = Glyph.new
      end
    end
  end
end

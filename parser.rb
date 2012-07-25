require "./debug"
require "./knowledge"
require "./vt"

# The Parser keeps track of the current state of the nethack output (inventory,
# character creation, player action, etc.) and routes information to the
# Knowledge base by scraping the screen.
#
# The Parser is also responsible for handling interface-related actions, such
# as pressing space when "--More--" is displayed, and navigating menus as
# requested by the AI

module Parser
  @state = :startup
  PARSER_STATES = [ :startup, :player_action, :inventory, :messages, :rendering ]

  LINEHANDLERS={ 1 => "top_line",
                23 => "attribute_line",
                24 => "status_line"}

  # the stream that takes in our data
  STREAM = VT102::Stream.new

  # contains the contents of the VT as a player would see them
  ACCUM_SCREEN = VT102::Screen.new

  # contains data printed to the VT since the last Parser frame
  FRAME_SCREEN = VT102::Screen.new

  STREAM.attach(ACCUM_SCREEN)
  STREAM.attach(FRAME_SCREEN)

  # scrape the VT for the currently displayed info. This assumes that the
  # current state of nethack is waiting for user input (i.e. that all printing
  # to the screen is finished until the player does something)

  def self.parse str
    return if str.empty?
    FRAME_SCREEN.clear_data
    STREAM.process str

    # log VT contents
    term ACCUM_SCREEN unless str.empty?
    Knowledge.parse_message FRAME_SCREEN.row_glyphs(1).join

    for action in [ :handle_more ]
      result = Parser.send(action)
      break if result != nil
    end

    if result === nil
      # no handlers were triggered, we must be ready for input, and everything
      # printed should be map info
      for i in 2..21
        for j in 1..79
          Knowledge.parse_glyph ACCUM_SCREEN.glyph(i, j), i - 1, j
        end
      end
      # The VT's cursor position should be on top of the player
      # We must translate from screen coords to world coords
      screen_row, screencol = ACCUM_SCREEN.position
      Knowledge.player.position = [screen_row - 1, screencol]
      extra Knowledge.dungeon_map.dump
    end

    return result
  end

  def self.parse_top_line str, chunk
    @@messages.push(chunk)
    extra("Found message %s", str)
  end

  def self.parse_attribute_line str, chunk
    #@attributes = [@attributes[-1..i].to_s, str, @attributes[i + str.length..@attributes.length-1]].join
    Knowledge.parse_attributes str
  end

  def self.parse_status_line str, chunk
    Knowledge.parse_status str
    extra("Found status %s", str)
  end

  def self.handle_more
    return /--More--/.match(FRAME_SCREEN.all) ? ' ' : nil
  end
end

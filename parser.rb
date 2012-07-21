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

  # contains the contents of the VT as a player would see them
  PERSISTENT_VT = VT::VTBuffer.new

  # contains data printed to the VT since the last Parser frame
  FRAME_VT = VT::VTBuffer.new

  # scrape the VT for the currently displayed info. This assumes that the
  # current state of nethack is waiting for user input (i.e. that all printing
  # to the screen is finished until the player does something)

  def self.parse str
    PERSISTENT_VT.parse str
    FRAME_VT.parse str
    # log VT contents
    term PERSISTENT_VT.dump unless str.empty?

    Knowledge.parse_message FRAME_VT.row(0)

    for action in [ :handle_more ]
      result = Parser.send(action)
      break if result != nil
    end

    if result === nil
      # no handlers were triggered, we must be ready for input
      row_glyphs = PERSISTENT_VT.row_glyphs
      for i in 1..21
        row_glyphs[i].each_index do |j|
          Knowledge.parse_glyph row_glyphs[i][j], i, j
        end
      end
      extra Knowledge.dungeon_map.dump
    end

    FRAME_VT.clear_data

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
    return /--More--/.match(FRAME_VT.all) ? ' ' : nil
  end
end

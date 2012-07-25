require "./debug"
require "./map"
require "./player_status"
require "./event_bus"

# The Knowledge module recieves information from the Parser and acts to store
# the programs collective knowledge of the present nethack universe. This includes
# things such as the player's current state (as a PlayerStatus), as well as maps
# of monster, item, and dungeon feature locations (as Map objects)

module Knowledge
  @player = PlayerStatus.new

  @dungeon_map = Map.new
  @down_stairs = nil

  # callbacks
  EventBus.on :down_stairs, ->() do
    @dungeon_map.fill_nil
  end

  ATTRIBUTES_REGEX=/^(\w+)?.*?St:(\d+(?:\/(?:\*\*|\d+))?) Dx:(\d+) Co:(\d+) In:(\d+) Wi:(\d+) Ch:(\d+)\s*(\w+)\s*(.*)$/

  # retrieves the location of the down stairs on this level
  # XXX: this is a shim
  def self.down_stairs
    @down_stairs
  end

  # Identify glyph and update the necessary knowledge maps
  def self.parse_glyph glyph, i, j
    if glyph.to_thing != :unknown
      @dungeon_map[i - 1][j - 1] = glyph.to_thing
    end
    if @dungeon_map[i - 1][j - 1] == :down_stairs
      @down_stairs = [i, j]
    end
  end

  def self.parse_message str
    dbg "found message\n'#{str}'" unless str.strip.empty?
    if str.match /(You fall through...|down the stairs)/
      EventBus.fire :down_stairs
    end
  end

  def self.parse_attributes str
    dbg("parsing attributes\n%s", str)
    result = ATTRIBUTES_REGEX.match(str)
    if result == nil
      dbg("Couldn't parse attributes\n%s")
      return
    else
      dbg("%s", result)
    end
    @player.str = result[2].to_i
    @player.dex = result[3].to_i
    @player.con = result[4].to_i
    @player.int = result[5].to_i
    @player.wis = result[6].to_i
    @player.cha = result[7].to_i
    dbg("Str: %s\nDex: %s\nCon: %s\nInt: %s\n", @player.str, @player.dex, @player.con, @player.int)
  end

  def self.parse_status str
  end

  # returns the string of movement characters to get from row1, col1 to row2,
  # col2 in the dungeon
  def self.find_path row1, col1, row2, col2
  end

  def self.player
    @player
  end

  def self.dungeon_map
    @dungeon_map
  end
end

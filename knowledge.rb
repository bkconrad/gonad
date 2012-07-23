require "./debug"
require "./map"
require "./player_status"

# The Knowledge module recieves information from the Parser and acts to store
# the programs collective knowledge of the present nethack universe. This includes
# things such as the player's current state (as a PlayerStatus), as well as maps
# of monster, item, and dungeon feature locations (as Map objects)

module Knowledge
  @player = PlayerStatus.new

  @dungeon_map = Map.new

  ATTRIBUTES_REGEX=/^(\w+)?.*?St:(\d+(?:\/(?:\*\*|\d+))?) Dx:(\d+) Co:(\d+) In:(\d+) Wi:(\d+) Ch:(\d+)\s*(\w+)\s*(.*)$/

  # Identify glyph and update the necessary knowledge maps
  def self.parse_glyph glyph, row, col
    @dungeon_map[row][col] = glyph.to_thing
  end

  def self.parse_message str
    dbg "found message\n'#{str}'" unless str.strip.empty?
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

  def self.dungeon_map
    @dungeon_map
  end
end

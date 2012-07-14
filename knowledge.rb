require "./debug"
require "./player_status"
module Knowledge
  @player = PlayerStatus.new

  ATTRIBUTES_REGEX=/^(\w+)?.*?St:(\d+(?:\/(?:\*\*|\d+))?) Dx:(\d+) Co:(\d+) In:(\d+) Wi:(\d+) Ch:(\d+)\s*(\w+)\s*(.*)$/
  def self.parse_message str
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
end

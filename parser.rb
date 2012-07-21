require "./debug"
require "./knowledge"
require "./vt"

# The Parser keeps track of the current state of the nethack output (inventory,
# character creation, player action, etc.) and routes information to the
# Knowledge base.
#
# The Parser is also responsible for handling interface-related actions, such
# as pressing space when "--More--" is displayed, and navigating menus as
# requested by the AI

module Parser

  # a stack of parser states (waiting, inventory, main, etc)
  @state_stack = []

  LINEHANDLERS={ 1 => "top_line",
                23 => "attribute_line",
                24 => "status_line"}

  ACTIONS = [ :handle_more ]
  def self.parse str
    VT.parse str

    for action in ACTIONS
      # this doesn't work for static methods.
      result = Parser.send(action, str)
      return result unless result === nil
    end
    return nil
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

  def self.handle_more str
    return /--More--/.match(str) ? ' ' : nil
  end
end

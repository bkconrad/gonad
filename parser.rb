require "./debug"
require "./knowledge"
require "./vt"
module Parser
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

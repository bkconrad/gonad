require "./debug"
module Parser
  class ColorCode
    attr_accessor :fg, :bg
  end
  ESC="\e"
  CODES=["A","C","m","h", "J","H","K"]

  def self.parse str
    i = 0
    while i < str.length
      if str[i] == ESC
        parse_escape str, i
      end
      i += 1
    end
  end

  def self.parse_escape str, i
    j = i + 1
    while !CODES.include?(str[j])
      if str[j] == ESC
        Debug.log("unexpected escape in %s", str[i..j])
        exit
      end
      j += 1
    end
    Debug.log("Found escape code %s", str[i..j])
    str[i..j]
  end
end

module Debug
  def self.start
    @@file = open("./debug.log", "a")
    print("Opened %s for writing", @@file.path)
  end

  def self.stop
    @@file.close
  end

  def self.print (str, *args)
    return if str.strip == ""
    str.tr!("%","")
    @@file.printf(str + "\n", args)
    @@file.flush
  end
end

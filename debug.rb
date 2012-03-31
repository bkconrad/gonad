module Debug
  def self.start
    @@logfile = open("./debug.log", "a")
    log("Opened %s for writing", @@logfile.path)
    @@rawfile = open("./raw.log", "a")
    log("Opened %s for writing", @@rawfile.path)
  end

  def self.stop
    @@logfile.close
    @@rawfile.close
  end

  def self.print (file, str, *args)
    return if str.strip == ""
    file.printf(str + "\n", args)
    file.flush
  end

  def self.log (str, *args)
    print(@@logfile, str, *args)
  end

  def self.raw (str, *args)
    str.sub!("%","%%")
    print(@@rawfile, str, *args)
  end
end

# I'd rather make this an enum
NONE = 0
ERROR = 1
LOG = 2
WARN = 3
DEBUG = 4
EXTRA = 5

module Debug
  def self.start
    @@debuglevel = ($options["loglevel"] || DEBUG).to_i
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

  def self.print_to_log (level, str, *args)
    print(@@logfile, str, *args) if @@debuglevel >= level
  end

  def self.raw (str, *args)
    while str.sub!(/([^%])%([^%])/,"\\1%%\\2")
    end
    print(@@rawfile, str + "\n", *args)
  end
end
  
def log str, *args
  Debug.print_to_log LOG, str, *args
end

def err str, *args
  Debug.print_to_log ERROR, str, *args
  exit
end

def dbg str, *args
  Debug.print_to_log DEBUG, str, *args
end

def extra str, *args
  Debug.print_to_log EXTRA, str, *args
end

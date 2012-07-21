# I'd rather make this an enum
NONE = 0
ERROR = 1
LOG = 2
WARN = 3
DEBUG = 4
EXTRA = 5

module Debug
  LOGBASENAMES = [ :raw, :term, :debug ]
  @@log_files = {}

  def self.start
    @@debuglevel = ($options["loglevel"] || DEBUG).to_i

    LOGBASENAMES.each do |base_name|
      open_log base_name
    end
  end

  def self.open_log base_name
    new_file = open("./#{base_name}.log", "w")
    @@log_files[base_name] = new_file
  end

  # cleanly close all open log files
  def self.stop
    for file in @@log_files.values
      file.close
    end
  end

  def self.print (file, str, *args)
    return if str.strip == ""
    file.printf(str + "\n", *args)
    file.flush
    str
  end

  # print to the log if the message is important enough
  def self.log (level, message, *args)
    print(@@log_files[:debug], message, *args) if @@debuglevel >= level
  end

  def self.raw (str, *args)
    # TODO: wtf does this do...
    while str.sub!(/([^%])%([^%])/,"\\1%%\\2")
    end
    print(@@log_files[:raw], str + "\n", *args)
  end

  def self.term (str)
    # TODO: why does this not use Debug.print() ?
    @@log_files[:term].print(str)   
  end
end
  
def log str, *args
  Debug.log LOG, str, *args
end

def err str, *args
  Debug.log ERROR, str, *args
  exit
end

def dbg str, *args
  Debug.log DEBUG, str, *args
end

def extra str, *args
  Debug.log EXTRA, str, *args
end

def term str
  Debug.term str
end

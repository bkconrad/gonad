#!/usr/bin/env ruby

# a map of regexes to event names which should be triggered when the message is
# encountered
MESSAGES = {
    /You fall through\.\.\./ => :down_stairs,
    /down the stairs/ => :down_stairs
}

require "logger"

require "./eddn/data"
require "./eddn/parser"
require "./eddn/client"

module Traikoa
  # EDDN ([GitHub](https://github.com/jamesremuscat/EDDN))
  module EDDN
    # EDDN version
    VERSION = "0.6.2"

    # EDDN TCP relay URL
    RELAY_URL = "tcp://eddn-relay.elite-markets.net:9500"

    # Logger for gateway Events
    LOGGER = Logger.new(STDOUT)
  end
end

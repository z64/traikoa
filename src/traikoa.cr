require "./traikoa/*"

module Traikoa
  client = EDDN::Client.new
  client.run!
end

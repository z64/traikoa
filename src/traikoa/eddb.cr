require "http/client"
require "json"

require "./eddb/*"

# Module for updating the database from EDDB's JSON dumps.
module Traikoa::EDDB
  macro call_update(object)
    HTTP::Client.get({{object}}::URL) do |response|
      parser = JSON::PullParser.new(response.body_io)
      parser.read_array do
        {{object}}.from_json(parser.read_raw).update!
      end
    end
  end

  call_update StarSystem

  call_update Station

  call_update Faction
end


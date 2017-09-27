require "./traikoa/*"

module Traikoa
  client = EDDN::Client.new

  # The general EDDN packet handler. This uses a JSON pull parser to seek
  # through the packet's message as to not have any dependencies on the
  # EDDN data objects, and ultimately be more DRY / flexible. None of this
  # data needs to be validated since it is simply for logging/auditing purposes,
  # debugging, and to eventually be consumed by other components of the
  # application.
  client.on_packet do |packet|
    header = packet.header
    message = packet.message

    # Set up some variable to store what we might get from reading the packet
    event_type = EDDN::PAYLOAD[packet.schema_ref]?
    event_string = nil
    system_name = nil
    station_name = nil
    position = [] of Float64

    # Set up a PullParser from the inner packet IO
    parser = JSON::PullParser.new(message)

    # Scan through the JSON for keys of interest, taking care to use aliases
    # for the "same property" across different payloads.
    parser.read_object do |key|
      case key
      when "StarSystem" || "systemName"
        system_name = parser.read_string
      when "StationName" || "stationName"
        station_name = parser.read_string
      when "StarPos"
        parser.read_array do
          position << parser.read_float
        end
      when "event"
        event_string = parser.read_string
      else
        parser.skip
      end
    end

    message.rewind

    # Basically, if the event wasn't a Journal event, we will not have read
    # "event" in the above pull parser, and we can just stringify the class
    # name.
    event_string ||= event_type.to_s.split("::").last

    # Chuck it in the DB!
    Database::EddnLog.create({
      gateway_timestamp: header.gateway_timestamp,
      type:              event_string,
      uploader_id:       header.uploader_id,
      software_name:     header.software_name,
      software_version:  header.software_version,
      schema_ref:        packet.schema_ref,
      system_name:       system_name,
      system_position:   position,
      station_name:      station_name,
      message:           message.to_s,
    })
  end

  client.run!
end

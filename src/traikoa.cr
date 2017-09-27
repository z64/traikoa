require "./traikoa/*"

module Traikoa
  client = EDDN::Client.new

  client.on_packet do |packet|
    header = packet.header

    event_type = EDDN::PAYLOAD[packet.schema_ref]?

    system_name = nil
    station_name = nil
    position = [] of Float64

    # Read the specific `Journal` event type
    event_string = if event_type == EDDN::Journal
                     object = packet.read_event.as(EDDN::Journal::Common)
                     system_name = object.star_system
                     position = object.star_position
                     if object.responds_to?(:station_name)
                       station_name = object.station_name
                     end
                     object.event
                   elsif event_type
                     event_type.to_s.split("::").last
                   else
                     "Unsupported"
                   end

    if event_type == EDDN::Commodity::Market
      object = packet.read_event
      system_name = object.as(EDDN::Commodity::Market).system_name
      station_name = object.as(EDDN::Commodity::Market).station_name
    end

    packet.message.rewind

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
      message:           packet.message.to_s,
    })
  end

  client.run!
end

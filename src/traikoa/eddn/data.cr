require "json"

module Traikoa
  module EDDN
    # Timestamp date format
    DATE_FORMAT = Time::Format.new("%FT%T.%L%:z")

    # Supported gateway payloads
    @[Flags]
    enum Payload
      Blackmarket
      Commodity
      Journal
      Outfitting
      Shipyard
    end

    # Mapping of schema URL to payload type that we can use for checking
    # to perform special handling on each.
    PAYLOAD = {
      "http://schemas.elite-markets.net/eddn/blackmarket/1" => Payload::Blackmarket,
      "http://schemas.elite-markets.net/eddn/commodity/3"   => Payload::Commodity,
      "http://schemas.elite-markets.net/eddn/journal/1"     => Payload::Journal,
      "http://schemas.elite-markets.net/eddn/outfitting/2"  => Payload::Outfitting,
      "http://schemas.elite-markets.net/eddn/shipyard/2"    => Payload::Shipyard,
    }

    # Packet header
    struct Header
      JSON.mapping({
        uploader_id:       {key: %(uploaderID), type: String},
        software_name:     {key: %(softwareName), type: String},
        software_version:  {key: %(softwareVersion), type: String},
        gateway_timestamp: {key: %(gatewayTimestamp), type: Time, converter: DATE_FORMAT},
      })
    end

    # A generic packet caught by the TCP relay
    struct Packet
      # Packet header
      getter header : Header?

      # Schema reference URL
      getter schema_ref : String?

      # Gateway message
      getter message : IO::Memory

      def initialize(@header, @schema_ref, @message)
      end
    end

    module Journal
      # Kinds of journal events
      Events = {"Docked", "FSDJump", "Scan"}

      # The following macro generates a set of structs that have different
      # data points depending on the kind of event. This is to get around
      # the fact you can't inhert/mix a JSON::Mapping that has keys common
      # to a family of objects.
      {% for kind in Events %}
        struct {{kind.id}}
          JSON.mapping({
            timestamp:     {type: String},
            star_system:   {key: "StarSystem", type: String},
            star_position: {key: "StarPos", type: Array(Float64)},
            {% if kind == "FSDJump" %}
              system_security: {key: "SystemSecurity", type: String}
            {% end %}
          })
        end
      {% end %}
    end
  end
end

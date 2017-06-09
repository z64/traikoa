require "json"
require "./localizer"

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
      "http://schemas.elite-markets.net/eddn/blackmarket/1" => Blackmarket,
      "http://schemas.elite-markets.net/eddn/commodity/3"   => Commodity,
      "http://schemas.elite-markets.net/eddn/journal/1"     => Journal,
      "http://schemas.elite-markets.net/eddn/outfitting/2"  => Outfitting,
      "http://schemas.elite-markets.net/eddn/shipyard/2"    => Shipyard,
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
      getter header : Header

      # Schema reference URL
      getter schema_ref : String

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
              security:                    {key: "SystemSecurity", type: String, converter: SecurityLocalizer},
              allegiance:                  {key: "SystemAllegiance", type: String},
              economy:                     {key: "SystemEconomy", type: String, converter: EconomyLocalizer},
              powerplay_state:             {key: "PowerplayState", type: String?},
              powers:                      {key: "Powers", type: Array(String)?},
              controlling_faction_state:   {key: "FactionState", type: String?, converter: FactionstateLocalizer},
              controlling_faction:         {key: "SystemFaction", type: String?},
              faction_presences:           {key: "Factions", type: Array(FactionPresence)?},
            {% end %}
          })
        end
      {% end %}

      struct FactionPresence
        JSON.mapping({
          allegiance: {key: "Allegiance", type: String},
          influence:  {key: "Influence", type: Float64},
          state:      {key: "FactionState", type: String},
          name:       {key: "Name", type: String},
          government: {key: "Government", type: String},
        })
      end
    end
  end
end

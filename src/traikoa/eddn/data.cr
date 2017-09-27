require "json"
require "./localizer"

module Traikoa
  module EDDN
    # Mapping of schema URL to payload type that we can use for checking
    # to perform special handling on each.
    PAYLOAD = {
      "https://eddn.edcd.io/schemas/blackmarket/1" => Blackmarket,
      "https://eddn.edcd.io/schemas/commodity/3"   => Commodity,
      "https://eddn.edcd.io/schemas/journal/1"     => Journal,
      "https://eddn.edcd.io/schemas/outfitting/2"  => Outfitting,
      "https://eddn.edcd.io/schemas/shipyard/2"    => Shipyard,
    }

    # Packet header
    struct Header
      TIME_FORMAT = Time::Format.new("%FT%T.%L%:z")

      JSON.mapping(
        uploader_id: {key: "uploaderID", type: String},
        software_name: {key: "softwareName", type: String},
        software_version: {key: "softwareVersion", type: String},
        gateway_timestamp: {key: "gatewayTimestamp", type: Time, converter: TIME_FORMAT}
      )
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

    # `Commodity` covers market-related EDDN payloads.
    module Commodity
      # A market within a station
      struct Market
        JSON.mapping(
          system_name: {key: "systemName", type: String},
          station_name: {key: "stationName", type: String},
          commodities: Array(MarketItem)
        )
      end

      # An individual item on the market board
      struct MarketItem
        JSON.mapping(
          demand_bracket: {key: "demandBracket", type: UInt16},
          name: String,
          buy_price: {key: "buyPrice", type: UInt64},
          mean_price: {key: "meanPrice", type: UInt64},
          stock_bracket: {key: "stockBracket", type: UInt16},
          demand: UInt64,
          sell_price: {key: "sellPrice", type: UInt64},
          stock: UInt64
        )
      end
    end

    # Events pushed to EDDN as parsed from Elite's player journal files
    module Journal
      # Kinds of journal events
      Events = {
        "Docked",
        "FSDJump",
        "Scan",
        "Location",
      }

      TIME_FORMAT = Time::Format.new("%FT%TZ")

      # Common attributes to all `Journal` events.
      # These are enforced as being present on all EDDN payloads.
      abstract struct Common
        # Extends the base `JSON.mapping` with the common attributs
        macro mapping(**properties)
          JSON.mapping(
            event: String,
            timestamp: {type: Time, converter: TIME_FORMAT},
            star_system: {key: "StarSystem", type: String},
            star_position: {key: "StarPos", type: Array(Float64)},
            {{properties.stringify[1...-1].id}}
          )
        end
      end

      # Data object for an EDDN Journal `Docked` event
      struct Docked < Common
        mapping(
          station_faction: {key: "StationFaction", type: String},
          station_faction_government: {key: "StationGovernment", type: String, converter: Localizer::Government},
          station_faction_economy: {key: "StationEconomy", type: String, converter: Localizer::Economy},
          distance_from_star: {key: "DistFromStarLS", type: Float64},
          station_type: {key: "StationType", type: String},
          station_name: {key: "StationName", type: String},
          station_services: {key: "StationServices", type: Array(String)}
        )
      end

      # Data object for an EDDN Journal `FSDJump` and `Location` events
      struct FSDJumpLocation < Common
        mapping(
          security: {key: "SystemSecurity", type: String, converter: Localizer::Security},
          allegiance: {key: "SystemAllegiance", type: String},
          economy: {key: "SystemEconomy", type: String, converter: Localizer::Economy},
          powerplay_state: {key: "PowerplayState", type: String?},
          powers: {key: "Powers", type: Array(String)?},
          controlling_faction_state: {key: "FactionState", type: String?, converter: Localizer::Factionstate},
          controlling_faction: {key: "SystemFaction", type: String?},
          controlling_faction_government: {key: "SystemGovernment", type: String?, converter: Localizer::Government},
          factions: {key: "Factions", type: Array(Faction)?},
          docked: {key: "Docked", type: Bool?},
          station_type: {key: "StationType", type: String?},
          station_name: {key: "StationName", type: String?},
          population: {key: "Population", type: UInt64}
        )
      end

      # Aliases for easy decoding
      alias FSDJump = FSDJumpLocation
      alias Location = FSDJumpLocation

      # Data object for an EDDN Journal `Scan` event
      struct Scan < Common
        mapping(
          atmosphere_composition: {key: "AtmosphereComposition", type: Array(AtmosphereComponent)?},
          terraform_state: {key: "TerraformState", type: String?},
          mass: {key: "MassEM", type: Float64?},
          planet_class: {key: "PlanetClass", type: String?},
          surface_pressure: {key: "SurfacePressure", type: Float64?},
          rotation_period: {key: "RotationPeriod", type: Float64?},
          orbital_period: {key: "OrbitalPeriod", type: Float64?},
          eccentricity: {key: "Eccentricity", type: Float64?},
          atmosphere_type: {key: "AtmosphereType", type: String?},
          surface_temperature: {key: "SurfaceTemperature", type: Float64?},
          tidal_lock: {key: "TidalLock", type: Bool?},
          periapsis: {key: "Periapsis", type: Float64?},
          body_name: {key: "BodyName", type: String},
          semi_major_axis: {key: "SemiMajorAxis", type: Float64?},
          materials: {key: "Materials", type: Array(Material)?},
          volcanism: {key: "Volcanism", type: String?},
          atmosphere: {key: "Atmosphere", type: String?},
          orbital_inclination: {key: "OrbitalInclination", type: Float64?},
          landable: {key: "Landable", type: Bool?},
          radius: {key: "Radius", type: Float64?},
          absolute_magnitude: {key: "AbsoluteMagnitude", type: Float64?},
          distance_from_arrival: {key: "DistanceFromArrivalLS", type: Float64},
          surface_gravity: {key: "SurfaceGravity", type: Float64?},
          stellar_mass: {key: "StellarMass", type: Float64?},
          star_type: {key: "StarType", type: String?},
          age: {key: "Age_MY", type: Int64?},
          luminosity: {key: "Luminosity", type: String?}
        )
      end

      # Faction presence sent with a `FSDJump` event
      struct Faction
        JSON.mapping(
          allegiance: {key: "Allegiance", type: String},
          influence: {key: "Influence", type: Float64},
          state: {key: "FactionState", type: String, converter: Localizer::Factionstate},
          name: {key: "Name", type: String},
          government: {key: "Government", type: String},
          pending_states: {key: "PendingStates", type: Array(FactionState)?},
          recovering_states: {key: "RecoveringStates", type: Array(FactionState)?}
        )
      end

      # Faction state within a `Faction` object
      struct FactionState
        JSON.mapping(
          state: {key: "State", type: String},
          trend: {key: "Trend", type: Int32}
        )
      end

      # Material presence within a `Scan` event
      struct Material
        JSON.mapping(
          percent: {key: "Percent", type: Float64},
          name: {key: "Name", type: String}
        )
      end

      # Atmosphere presence within a `Scan` event
      struct AtmosphereComponent
        JSON.mapping(
          percent: {key: "Percent", type: Float64},
          name: {key: "Name", type: String}
        )
      end
    end
  end
end

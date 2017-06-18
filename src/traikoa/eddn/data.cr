require "json"
require "./localizer"

module Traikoa
  module EDDN
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
      TIME_FORMAT = Time::Format.new("%FT%T.%L%:z")

      JSON.mapping({
        uploader_id:       {key: "uploaderID", type: String},
        software_name:     {key: "softwareName", type: String},
        software_version:  {key: "softwareVersion", type: String},
        gateway_timestamp: {key: "gatewayTimestamp", type: Time, converter: TIME_FORMAT},
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

    module Commodity
      struct Market
        JSON.mapping({
          system_name:  {key: "systemName", type: String},
          station_name: {key: "stationName", type: String},
          commodities:  Array(MarketItem),
        })
      end

      struct MarketItem
        JSON.mapping({
          demand_bracket: {key: "demandBracket", type: UInt16},
          name:           String,
          buy_price:      {key: "buyPrice", type: UInt64},
          mean_price:     {key: "meanPrice", type: UInt64},
          stock_bracket:  {key: "stockBracket", type: UInt16},
          demand:         UInt64,
          sell_price:     {key: "sellPrice", type: UInt64},
          stock:          UInt64,
        })
      end
    end

    module Journal
      # Kinds of journal events
      Events = {
        "Docked",
        "FSDJump",
        "Scan",
      }

      TIME_FORMAT = Time::Format.new("%FT%TZ")

      # The following macro generates a set of structs that have different
      # data points depending on the kind of event. This is to get around
      # the fact you can't inhert/mix a JSON::Mapping that has keys common
      # to a family of objects.
      {% for kind in Events %}
        struct {{kind.id}}
          JSON.mapping({
            timestamp:     {type: Time, converter: TIME_FORMAT},
            star_system:   {key: "StarSystem", type: String},
            star_position: {key: "StarPos", type: Array(Float64)},
            {% if kind == "Docked" %}
              station_faction:            {key: "StationFaction", type: String},
              station_faction_government: {key: "StationGovernment", type: String, converter: Localizer::Government},
              station_faction_economy:    {key: "StationEconomy", type: String, converter: Localizer::Economy},
              distance_from_star:         {key: "DistFromStarLS", type: Float64},
              station_type:               {key: "StationType", type: String},
              station_name:               {key: "StationName", type: String}
            {% end %}
            {% if kind == "FSDJump" %}
              security:                       {key: "SystemSecurity", type: String, converter: Localizer::Security},
              allegiance:                     {key: "SystemAllegiance", type: String},
              economy:                        {key: "SystemEconomy", type: String, converter: Localizer::Economy},
              powerplay_state:                {key: "PowerplayState", type: String?},
              powers:                         {key: "Powers", type: Array(String)?},
              controlling_faction_state:      {key: "FactionState", type: String?, converter: Localizer::Factionstate},
              controlling_faction:            {key: "SystemFaction", type: String?},
              controlling_faction_government: {key: "SystemGovernment", type: String?, converter: Localizer::Government},
              factions:                       {key: "Factions", type: Array(Faction)?},
            {% end %}
            {% if kind == "Scan" %}
              atmosphere_composition: {key: "AtmosphereComposition", type: Array(AtmosphereComponent)?},
              terraform_state:        {key: "TerraformState", type: String?},
              mass_em:                {key: "MassEM", type: Float64?},
              planet_class:           {key: "PlanetClass", type: String?},
              surface_pressure:       {key: "SurfacePressure", type: Float64?},
              rotation_period:        {key: "RotationPeriod", type: Float64},
              orbital_period:         {key: "OrbitalPeriod", type: Float64?},
              eccentricity:           {key: "Eccentricity", type: Float64?},
              atmosphere_type:        {key: "AtmosphereType", type: String?},
              surface_temperature:    {key: "SurfaceTemperature", type: Float64},
              tidal_lock:             {key: "TidalLock", type: Bool?},
              periapsis:              {key: "Periapsis", type: Float64?},
              body_name:              {key: "BodyName", type: String},
              semi_major_axis:        {key: "SemiMajorAxis", type: Float64?},
              materials:              {key: "Materials", type: Array(Material)?},
              volcanism:              {key: "Volcanism", type: String?},
              atmosphere:             {key: "Atmosphere", type: String?},
              orbital_inclination:    {key: "OrbitalInclination", type: Float64?},
              landable:               {key: "Landable", type: Bool?},
              radius:                 {key: "Radius", type: Float64},
              absolute_magnitude:     {key: "AbsoluteMagnitude", type: Float64?},
              distance_from_arrival:  {key: "DistanceFromArrivalLS", type: Float64},
              surface_gravity:        {key: "SurfaceGravity", type: Float64?},
              stellar_mass:           {key: "StellarMass", type: Float64?},
              star_type:              {key: "StarType", type: String?},
              age:                    {key: "Age_MY", type: Int64?}
            {% end %}
          })
        end
      {% end %}

      struct Faction
        JSON.mapping({
          allegiance: {key: "Allegiance", type: String},
          influence:  {key: "Influence", type: Float64},
          state:      {key: "FactionState", type: String, converter: Localizer::Factionstate},
          name:       {key: "Name", type: String},
          government: {key: "Government", type: String},
        })
      end

      struct Material
        JSON.mapping({
          percent: {key: "Percent", type: Float64},
          name:    {key: "Name", type: String},
        })
      end

      struct AtmosphereComponent
        JSON.mapping({
          percent: {key: "Percent", type: Float64},
          name:    {key: "Name", type: String},
        })
      end
    end
  end
end

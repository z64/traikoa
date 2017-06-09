require "csv"

module Traikoa
  module EDDN
    # Directory where CSVs to build localizations from are stored.
    CSV_DIR = "src/traikoa/eddn/FDevIDs"

    # A basic localization.
    record SimpleLocalization, id : String, name : String

    # Constructs a simple localizer converter to be used in a JSON.mapping
    macro simple_localizer(name)
      module {{name.id.capitalize}}Localizer
        @@localizations : Array(Traikoa::EDDN::SimpleLocalization)
        @@localizations = CSV.parse(File.read("#{CSV_DIR}/{{name}}.csv"))
                            .map do |e|
                              Traikoa::EDDN::SimpleLocalization.new(e[0], e[1])
                            end

        def self.localize(string)
          @@localizations.find { |local| local.id == string }.not_nil!.name
        end

        def self.from_json(parser)
          localize(parser.read_string)
        end
      end
    end

    # This doesn't compile classes with the "correct" casing,
    # but I preffered the convenience of keeping this DRY instead.
    {% for kind in ["economy",
                    "factionstate",
                    "government",
                    "rings",
                    "security",
                    "superpower",
                    "terraformingstate"] %}
      simple_localizer {{kind.id}}
    {% end %}
  end
end

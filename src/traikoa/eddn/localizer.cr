require "csv"

module Traikoa::EDDN
  # A collection of converters to localize in-game strings to their
  # human readable equivalents
  module Localizer
    # Directory where CSVs to build localizations from are stored.
    CSV_DIR = "src/traikoa/eddn/FDevIDs"

    # A basic localization.
    record SimpleLocalization, id : String, name : String

    # Constructs a simple localizer converter to be used in a JSON.mapping
    # This doesn't compile classes with the "correct" casing,
    # but I preffered the convenience of keeping this DRY instead.
    {% for name in ["economy",
                    "factionstate",
                    "government",
                    "rings",
                    "security",
                    "superpower",
                    "terraformingstate"] %}
      # A simple (ID to name) localizer interface for `{{name}}.csv`.
      # Converts a string like # `"$government_Communism;"` into "Communism"
      # ```
      # {{name.id.capitalize}}.localize("$some_game_string;") #=> "Localized String"
      # ```
      module {{name.id.capitalize}}
        @@localizations : Array(Traikoa::EDDN::Localizer::SimpleLocalization)
        @@localizations = CSV.parse(File.read("#{CSV_DIR}/{{name.id}}.csv"))
                             .map do |e|
                               Traikoa::EDDN::Localizer::SimpleLocalization.new(e[0], e[1])
                             end

        # Localizes a string from `{{name}}.csv`
        def self.localize(string)
          @@localizations.find { |local| local.id == string }.not_nil!.name
        end

        # Callback for using this localizer in a `JSON.mapping`'s `converter`
        def self.from_json(parser)
          localize(parser.read_string)
        end
      end
    {% end %}
  end
end

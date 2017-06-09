module Traikoa
  module EDDN
    # Parses a gateway message into a Packet
    def self.parse_message(message : String)
      parser = JSON::PullParser.new(message)

      header = nil
      schema_ref = nil
      data = IO::Memory.new

      parser.read_object do |key|
        case key
        when "header"
          header = Header.from_json(parser.read_raw)
        when "$schemaRef"
          schema_ref = parser.read_string
        when "message"
          # Read the raw JSON into memory for later
          JSON.build(data) do |builder|
            parser.read_raw(builder)
          end
        else
          parser.skip
        end
      end

      data.rewind

      Packet.new(
        header.not_nil!,
        schema_ref.not_nil!,
        data
      )
    end

    struct Packet
      # Deducts the kind of data object this event is mapped for
      # based on the schema_ref and parses it
      def read_event
        PAYLOAD[schema_ref].read_event(message)
      end
    end

    struct Blackmarket
      def self.read_event(message)
        raise "Not implemented"
      end
    end

    module Commodity
      def self.read_event(message)
        Market.from_json(message)
      end
    end

    module Journal
      # Pulls out the kind of journal event a message is for
      def self.read_event(message : IO::Memory)
        parser = JSON::PullParser.new(message)

        event = nil

        parser.on_key("event") { event = parser.read_string }

        message.rewind

        # Avoid some messy switch here with a macro to generate
        # a bunch of if return guards, and implicitly nil if
        # we don't have a match
        {% for kind in Events %}
          return {{kind.id}}.from_json message if event == {{kind}}
        {% end %}
      end
    end

    struct Outfitting
      def self.read_event(message)
        raise "Not implemented"
      end
    end

    struct Shipyard
      def self.read_event(message)
        raise "Not implemented"
      end
    end
  end
end

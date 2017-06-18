module Traikoa
  module EDDN
    struct Packet
      # Deducts the kind of data object this event is mapped for
      # based on the schema_ref and parses it
      def read_event
        PAYLOAD[schema_ref].read_event(message).not_nil!
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

    # Exception to raise on unimplemented events
    class NotImplemented < Exception
    end

    # TODO
    struct Blackmarket
      def self.read_event(message)
        raise NotImplemented.new(message.to_s)
      end
    end

    # TODO
    struct Outfitting
      def self.read_event(message)
        raise NotImplemented.new(message.to_s)
      end
    end

    # TODO
    struct Shipyard
      def self.read_event(message)
        raise NotImplemented.new(message.to_s)
      end
    end
  end
end

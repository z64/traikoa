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
  end
end

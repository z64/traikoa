require "zlib"
require "zeromq"

module Traikoa
  module EDDN
    # A client for managing a TCP ZeroMQ connection
    # to EDDN
    class Client
      @relay = ZMQ::Socket.create(ZMQ::Context.new, ZMQ::SUB)

      def initialize
        @relay.set_socket_option(ZMQ::SUBSCRIBE, "")
        LOGGER.info "initialized client"
      end

      # Establishes a TCP connection and starts
      # listening for dispatches. Dispatches are sent across
      # a returned channel.
      def run!
        LOGGER.info "connecting to #{RELAY_URL}"
        @relay.connect(RELAY_URL)

        LOGGER.info "entering main loop"
        loop do
          if data = @relay.receive_string
            inflated = Zlib::Reader.new(
              IO::Memory.new(data)
            ).gets_to_end

            packet = parse_message(inflated)

            begin
              dispatch packet
            rescue ex : NotImplemented
              LOGGER.warn "Payload not implemented! #{ex}"
            end
          end
        end
      end

      # Parses a gateway message into a Packet
      def parse_message(message : String)
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

      private def dispatch(packet : Packet)
        handle(packet)
        handle(packet.read_event)
      rescue ex : JSON::ParseException
        LOGGER.error <<-LOG
          An error occured while decoding packet message: #{ex.message}
          Packet: #{packet.inspect}
          Message: #{packet.message.to_s}
          LOG
      end

      # :nodoc:
      macro event(name, payload_type)
        # Raised when a `{{payload_type}}` is received from the gateway
        def on_{{name}}(&handler : {{payload_type}} ->)
          (@on_{{name}}_handlers ||= [] of {{payload_type}} ->) << handler
        end

        # :nodoc:
        def handle(object : {{payload_type}})
          @on_{{name}}_handlers.try &.each do |handler|
            begin
              handler.call(object)
            rescue ex
              LOGGER.error <<-LOG
                An unhandled exception occured in a gateway object handler!
                Exception: #{ex}
                Object: #{object.inspect}
                #{"Packet message: #{object.message.to_s}" if object.is_a?(Packet)}
                LOG
              raise ex
            end
          end
        end
      end

      event packet, Packet

      event journal_docked, Journal::Docked

      event journal_fsd_jump, Journal::FSDJump

      event journal_scan, Journal::Scan

      event market, Commodity::Market

      event blackmarket, Blackmarket

      event shipyard, Shipyard

      event outfitting, Outfitting

      event unknown_payload, Nil
    end
  end
end

require "zlib"
require "zeromq"

module Traikoa
  module EDDN
    # A client for managing a TCP ZeroMQ connection
    # to EDDN
    class Client
      @relay = ZMQ::Socket.create(ZMQ::Context.new, ZMQ::SUB)

      # @buffer = IO::Memory.new

      def initialize
        @relay.set_socket_option(ZMQ::SUBSCRIBE, "")
        LOGGER.info "initialized client"
      end

      # Establishes a TCP connection and starts
      # listening for dispatches. Dispatches are sent across
      # a provided channel.
      def run(channel : Channel(String))
        LOGGER.info "connecting to #{RELAY_URL}"
        @relay.connect(RELAY_URL)

        LOGGER.info "entering main loop"
        loop do
          data = @relay.receive_string
          if data
            deflated = Zlib::Inflate.new(
              IO::Memory.new(data)
            ).gets_to_end

            channel.send deflated
          end
        end
      end
    end
  end
end

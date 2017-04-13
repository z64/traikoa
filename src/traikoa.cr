require "./traikoa/*"

module Traikoa
  # Set up a fiber to listen to the relay dispatches
  relay_channel = Channel(String).new
  spawn do
    loop do
      relay_payload = relay_channel.receive
      EDDN::LOGGER.info EDDN.parse_message(relay_payload).inspect
    end
  end

  # Establish a connection and start handling dispatches
  EDDN::Client.new.run(channel)
end

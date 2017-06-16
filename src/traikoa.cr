require "./traikoa/*"

module Traikoa
  client = EDDN::Client.new

  relay_channel = client.run!

  loop do
    relay_payload = relay_channel.receive
    packet = EDDN.parse_message(relay_payload)
    begin
      EDDN::LOGGER.info packet.read_event
    rescue
      EDDN::LOGGER.info "(unsupported packet)"
    end
  end
end

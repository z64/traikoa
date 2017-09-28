require "jennifer/adapter/postgres"
require "jennifer"

Jennifer::Config.read("database.yml", :development)

# Sets the logger level
# TODO: Make this configurable
Jennifer::Config.logger.level = Logger::WARN

require "./database/utils"
require "./database/system"
require "./database/faction"
require "./database/eddn_log"

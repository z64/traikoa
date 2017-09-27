require "jennifer/adapter/postgres"
require "jennifer"

Jennifer::Config.read("database.yml", :development)

require "./database/utils"
require "./database/system"
require "./database/faction"
require "./database/eddn_log"

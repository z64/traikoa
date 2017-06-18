require "jennifer/adapter/postgres"
require "jennifer"

Jennifer::Config.read("database.yml", :development)

require "./database/*"

require "jennifer/adapter/postgres"
require "jennifer"

Jennifer::Config.read("database.yml", :development)

module Traikoa
  # Container for database classes (models, etc.)
  module Database
  end
end

require "json"
require "kemal"

# The current API version.
module Traikoa::API
  VERSION = 0
end

require "./api/error"
require "./api/scope"
require "./api/middleware"
require "./api/routes"

Kemal.run

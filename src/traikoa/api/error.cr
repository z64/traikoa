module Traikoa::API
  {% for code in [400, 401, 404, 405, 500] %}
    error({{code}}) do |env|
      errors = env.get("errors").as(ErrorContainer)
      {% if code == 404 %}
        errors.add(404_u32)
      {% end %}
      errors.to_json
    end
  {% end %}

  macro report_error(code)
    env.get("errors").as(ErrorContainer).add({{code}})
  end

  # A container for errors to collect during validation
  struct ErrorContainer
    getter errors = [] of Error

    JSON.mapping(errors: Array(Error))

    def initialize
    end

    # Adds any `Error` into this `ErrorContainer`
    def <<(error)
      @errors << error
    end

    # Adds an `Error` into this `ErrorContainer` by code
    def add(code)
      @errors << Error[code]
    end
  end

  # A canned API error response
  class Error
    # ID code of this error
    getter code : UInt32

    # Message associated with this error
    getter message : String

    JSON.mapping(code: UInt32, message: String)

    # Cache of instantiated `Error` objects
    class_getter errors = {} of UInt32 => Error

    def initialize(@code, @message)
      @@errors[@code] = self
    end

    # Yields this class to neatly build a set of errors
    #
    # ```
    # Error.build do
    #   error 401_u32, "Unauthorized"
    # end
    #
    # Error[401_u32] # => Error
    # ```
    def self.build
      with self yield
    end

    # Defines a new `Error`
    def self.error(code, message)
      new(code, message)
    end

    # Pulls an `Error` from the cache by `code`
    def self.[](code)
      errors[code]
    end
  end

  Error.build do
    error 401_u32, "Unauthorized"
    error 404_u32, "Not Found"
    error 500_u32, "Internal Server Error - Please report this! https://github.com/z64/traikoa/issues"
    error 10001_u32, "Unknown system"
    error 10002_u32, "Unknown station"
    error 10004_u32, "Unknown faction"
    error 40001_u32, "Unauthorized"
    error 40002_u32, "User-Agent missing"
  end
end

module Traikoa::API
  # Block any requests that do not supply a User-Agent
  before_all do |env|
    if env.request.headers["User_Agent"].empty?
      report_error(40001_u32)
      report_error(40002_u32)
      env.response.status_code = 401
    end
  end

  # Home route. Displays current time, the current API version,
  # and a fortune. I'm too obsessed with that program.
  get "/" do |env|
    {
      fortune: `fortune`.chomp,
      time:    Time.now,
      version: VERSION,
    }.to_json
  end
end

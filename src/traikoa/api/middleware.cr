module Traikoa::API
  add_context_storage_type(Traikoa::API::Scope)
  add_context_storage_type(Traikoa::API::ErrorContainer)

  class JSONHandler < Kemal::Handler
    def call(env)
      env.response.content_type = "application/json"

      # TODO Derive scope from the requesting user's Authorization
      env.set("scope", Scope["none"])
      env.set("errors", ErrorContainer.new)

      call_next(env)
    end
  end

  add_handler(JSONHandler.new)
end

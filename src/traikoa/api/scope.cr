module Traikoa::API
  # An enum of common HTTP methods.
  @[Flags]
  enum Method
    None
    Get
    Post
    Put
    Patch
    Delete
  end

  # A `Scope` describes a set of rules as to what
  # HTTP methods can be called on particular app routes.
  # Instances of `Scope` are cached.
  class Scope
    # Cache of instanced `Scope` objects, by name.
    class_getter scopes = {} of String => Scope

    # Name of this scope. Should be unique in order to be
    # cached properly.
    getter name : String

    # `@routes` is instantiated with a default of `Method::None`
    # so we don't have to deal with a `Nil` union type for
    # undefined routes.
    @routes = Hash(String, Method).new(Method::None)

    def initialize(@name)
      @@scopes[@name] = self
    end

    # Yields a new scope to be configured.
    #
    # ```
    # scope = Scope.build("basic") do
    #   add_route("/", Method::Get)
    #   add_route("/posts", Method::Get | Method::Post)
    #   add_route("/posts/:id", Method::Get | Method::Patch | Method::Delete)
    # end
    #
    # scope["/"].get?         # => true
    # scope["/posts"].post?   # => true
    # scope["/posts"].delete? # => false
    # scope["abc"]            # => Method::None
    # ```
    def self.build(name)
      with new(name) yield
    end

    # Adds a route to this scope with given
    # method flags.
    def route(path, method)
      @routes[path] = method
    end

    # Gets the methods allowed on this scope
    # for a particular route.
    def [](path)
      @routes[path]
    end

    # Pulls an instanced scope from the cache
    # by its name.
    def self.[](name)
      scopes[name]
    end

    def to_json
    end
  end

  Scope.build("none") do
    route "/", Method::Get
  end
end

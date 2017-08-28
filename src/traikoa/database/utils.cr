module Utils
  macro serialize(*fields)
    def to_json(builder : JSON::Builder)
      builder.start_object

      {% for field in fields %}
        builder.string({{field.stringify}})
        {{field}}.to_json(builder)
      {% end %}

      builder.end_object
    end
  end
end

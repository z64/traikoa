class StarSystem < Jennifer::Model::Base
  mapping(
    id: {type: Int32 | Int64, primary: true},
    created_at: {type: Time, null: false, default: Time.now},
    updated_at: {type: Time, null: false, default: Time.now},
    name: {type: String, null: false},
    position: {type: Array(Float64), null: false},
    security: {type: String, null: false},
    economy: {type: String, null: false},
    population: {type: Int64, null: true, default: 0i64},
    cc_value: {type: Int32, null: true, default: 0}
  )
end

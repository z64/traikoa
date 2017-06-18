class StarSystem < Jennifer::Model::Base
  mapping(
    id: {type: Int32, primary: true},
    last_updated: Time,
    name: String,
    position: {type: Array(Float64), null: false},
    security: {type: String, null: false},
    allegiance: {type: String, null: false},
    economy: {type: String, null: false},
    powerplay_state: {type: String, null: true},
    powers: {type: Array(String), null: true},
    controlling_faction_state: {type: String, null: true},
    controlling_faction: {type: String, null: true},
    controlling_faction_government: {type: String, null: true},
    population: {type: Int64, null: true, default: 0i64},
    cc_value: {type: Int32, null: true, default: 0},
  )
end

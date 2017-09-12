module Traikoa::Database
  class StarSystem < Jennifer::Model::Base
    table_name :star_systems

    mapping({
      id:         {type: Int32, primary: true},
      created_at: {type: Time, default: Time.now},
      updated_at: {type: Time, default: Time.now},
      name:       {type: String},
      position:   {type: Array(Float64)},
      security:   {type: String},
      economy:    {type: String},
      population: {type: Int64, default: 0i64},
      cc_value:   {type: Int32 | Int64, default: 0},
    })

    Utils.serialize(
      id, created_at, updated_at, name, position,
      security, economy, population, cc_value,
      faction_presences
    )

    has_many :faction_presences, FactionPresence, foreign: :star_system_id
  end
end

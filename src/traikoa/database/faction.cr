module Traikoa::Database
  class Faction < Jennifer::Model::Base
    table_name :factions

    mapping({
      id: {type: Int32, primary: true},
      created_at: {type: Time, default: Time.now},
      updated_at: {type: Time, default: Time.now},
      name: String,
      allegiance: String,
      government: String,
      state: String,
      player_faction: Bool,
      home_system_id: Int32,
    })

    Utils.serialize(
      id, created_at, updated_at, name, allegiance,
      government, state, player_faction, home_system_id
    )

    has_many :presences, FactionPresence
    belongs_to :home_system, StarSystem, foreign: :id
  end

  class FactionPresence < Jennifer::Model::Base
    table_name :faction_presences

    mapping({
      id: {type: Int32, primary: true},
      faction_id: Int32,
      star_system_id: Int32?,
      influence: Float64,
      controlling: Bool,
    })

    Utils.serialize(faction_id, influence, controlling, state_transitions)

    has_one :star_system, StarSystem
    has_one :faction, Faction, foreign: :id
    has_many :state_transitions, StateTransition, foreign: :faction_presence_id
  end

  class StateTransition < Jennifer::Model::Base
    table_name :state_transitions

    mapping({
      id: {type: Int32, primary: true},
      faction_presence_id: Int32,
      transition: String,
      state: String,
      trend: Int32
    })

    Utils.serialize(transition, state, trend)
  end
end

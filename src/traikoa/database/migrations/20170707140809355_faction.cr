class Faction20170707140809355 < Jennifer::Migration::Base
  def up
    exec <<-SQL
    CREATE TABLE factions (
      id BIGSERIAL PRIMARY KEY,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      name TEXT NOT NULL,
      allegiance ALLEGIANCE NOT NULL,
      government GOVERNMENT NOT NULL,
      state FACTION_STATE NOT NULL,
      player_faction BOOL DEFAULT false,
      home_system_id INTEGER REFERENCES star_systems(id) ON DELETE CASCADE
    );
    SQL

    exec <<-SQL
    CREATE UNIQUE INDEX faction_name_idx ON factions(name);
    SQL

    exec <<-SQL
    CREATE TABLE faction_presences (
      id BIGSERIAL PRIMARY KEY,
      faction_id INTEGER REFERENCES factions(id) ON DELETE CASCADE,
      star_system_id INTEGER REFERENCES star_systems(id) ON DELETE CASCADE,
      influence NUMERIC NOT NULL,
      controlling BOOLEAN NOT NULL
    );
    SQL

    exec <<-SQL
    CREATE UNIQUE INDEX presence_system_idx ON faction_presences(faction_id, star_system_id);
    SQL

    exec <<-SQL
    CREATE TYPE transition AS ENUM (
      'pending',
      'recovering'
    );
    SQL

    exec <<-SQL
    CREATE TABLE state_transitions (
      id BIGSERIAL PRIMARY KEY,
      faction_presence_id INTEGER REFERENCES faction_presences(id) ON DELETE CASCADE,
      transition TRANSITION NOT NULL,
      state FACTION_STATE NOT NULL,
      trend INTEGER NOT NULL,
      UNIQUE (faction_presence_id, transition)
    );
    SQL
  end

  def down
    exec <<-SQL
    DROP TABLE state_transitions;
    SQL

    exec <<-SQL
    DROP TABLE faction_presences;
    SQL

    exec <<-SQL
    DROP TABLE factions;
    SQL

    exec <<-SQL
    DROP TYPE transition;
    SQL
  end
end

class System20170618001337825 < Jennifer::Migration::Base
  def up
    exec <<-SQL
    CREATE TYPE allegiance AS ENUM (
      'None',
      'Alliance',
      'Empire',
      'Federation',
      'Independent',
      'Pirate'
    );
    SQL

    exec <<-SQL
    CREATE TYPE government AS ENUM (
      'None',
      'Anarchy',
      'Communism',
      'Confederacy',
      'Cooperative',
      'Corporate',
      'Democracy',
      'Dictatorship',
      'Feudal',
      'Imperial',
      'Patronage',
      'Prison Colony',
      'Theocracy',
      'Workshop'
    );
    SQL

    exec <<-SQL
    CREATE TYPE faction_state AS ENUM (
      'None',
      'Boom',
      'Bust',
      'Civil Unrest',
      'Civil War',
      'Election',
      'Expansion',
      'Famine',
      'Investment',
      'Lockdown',
      'Outbreak',
      'Retreat',
      'War'
    );
    SQL

    exec <<-SQL
    CREATE TYPE economy AS ENUM (
      'None',
      'Agriculture',
      'Colony',
      'Extraction',
      'High Tech',
      'Industrial',
      'Military',
      'Refinery',
      'Service',
      'Terraforming',
      'Tourism'
    );
    SQL

    exec <<-SQL
    CREATE TYPE security AS ENUM (
      'Anarchy',
      'Lawless',
      'High',
      'Low',
      'Medium'
    );
    SQL

    exec <<-SQL
    CREATE TABLE star_systems (
      id SERIAL PRIMARY KEY,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      name TEXT NOT NULL,
      position FLOAT[] NOT NULL,
      security SECURITY NOT NULL,
      economy ECONOMY NOT NULL,
      population BIGINT NOT NULL DEFAULT 0,
      cc_value BIGINT NOT NULL DEFAULT 0
    );
    SQL

    exec <<-SQL
    CREATE UNIQUE INDEX star_system_position_idx ON star_systems (position);
    SQL

    exec <<-SQL
    CREATE INDEX star_system_name_idx ON star_systems (name);
    SQL
  end

  def down
    exec <<-SQL
    DROP TABLE star_systems;
    SQL

    exec <<-SQL
    DROP TYPE allegiance;
    SQL

    exec <<-SQL
    DROP TYPE government;
    SQL

    exec <<-SQL
    DROP TYPE faction_state;
    SQL

    exec <<-SQL
    DROP TYPE economy;
    SQL

    exec <<-SQL
    DROP TYPE security;
    SQL
  end
end

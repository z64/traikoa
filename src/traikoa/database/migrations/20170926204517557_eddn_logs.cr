class EddnLogs20170926204517557 < Jennifer::Migration::Base
  def up
    exec <<-SQL
    CREATE TYPE eddn_event AS ENUM (
      'Docked',
      'FSDJump',
      'Location',
      'Scan',
      'CommodityMarket',
      'Blackmarket',
      'Shipyard',
      'Outfitting',
      'Unsupported'
    );
    SQL

    exec <<-SQL
    CREATE TABLE eddn_logs (
      id SERIAL PRIMARY KEY,
      gateway_timestamp TIMESTAMPTZ NOT NULL,
      type EDDN_EVENT NOT NULL,
      uploader_id TEXT NOT NULL,
      software_name TEXT NOT NULL,
      software_version TEXT NOT NULL,
      schema_ref TEXT NOT NULL,
      system_name TEXT,
      system_position FLOAT[],
      station_name TEXT,
      message TEXT NOT NULL
    );
    SQL

    exec <<-SQL
    CREATE INDEX eddn_logs_gateway_timestamp_idx ON eddn_logs (gateway_timestamp);
    SQL

    exec <<-SQL
    CREATE INDEX eddn_logs_type_idx ON eddn_logs (type);
    SQL

    exec <<-SQL
    CREATE INDEX eddn_logs_schema_ref_idx ON eddn_logs (schema_ref);
    SQL
  end

  def down
    exec <<-SQL
    DROP TABLE IF EXISTS eddn_logs;
    SQL

    exec <<-SQL
    DROP TYPE IF EXISTS eddn_event
    SQL
  end
end

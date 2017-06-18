class System20170618001337825 < Jennifer::Migration::Base
  def up
    create_table(:star_systems) do |t|
      t.integer :id, {:primary => true, :auto_increment => true}
      t.timestamp :updated_at, {:null => false}
      t.string :name, {:null => false}
      t.field :position, :"float[]", {:unique => true}
      t.string :security, {:null => false}
      t.string :allegiance, {:null => false}
      t.string :economy, {:null => false}
      t.string :powerplay_state
      t.field :powers, :"text[]"
      t.string :controlling_faction_state
      t.string :controlling_faction
      t.string :controlling_faction_government
      t.field :population, :bigint, {:default => 0}
      t.integer :cc_value, {:default => 0}
    end

    exec <<-SQL
      CREATE UNIQUE INDEX star_system_position_idx ON star_systems (position);
      SQL
  end

  def down
    drop_table(:star_systems)
  end
end

class AddExtraFieldResolvedAtEmergencies < ActiveRecord::Migration
  def self.up
    add_column :emergencies, :resolved_at, :datetime
  end
  def self.down
  end
end

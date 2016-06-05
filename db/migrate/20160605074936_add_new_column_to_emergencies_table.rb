class AddNewColumnToEmergenciesTable < ActiveRecord::Migration
  def self.up
    add_column :emergencies, :responders, :text, array: true, default: []
  end
  def self.down

  end
end

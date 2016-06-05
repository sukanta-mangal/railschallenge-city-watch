class AddNewColumnToResponders < ActiveRecord::Migration
  def self.up
    add_column :responders, :emergency_code, :string
  end
  def self.down

  end
end

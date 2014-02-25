class UserParametersDev < ActiveRecord::Migration
  def self.up
    add_column :users, :dev, :integer
  end

  def self.down
    remove_column :users, :dev
  end
end
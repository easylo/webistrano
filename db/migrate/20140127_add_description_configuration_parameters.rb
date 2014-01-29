class AddDescriptionConfigurationParameters < ActiveRecord::Migration
  def self.up
    add_column :configuration_parameters, :description, :string, :default => ''
  end

  def self.down
    remove_column :configuration_parameters, :description
  end
end
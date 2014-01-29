class AddHostIdConfigurationParameters < ActiveRecord::Migration
  def self.up
    add_column :configuration_parameters, :host_id, :integer
  end

  def self.down
    remove_column :configuration_parameters, :host_id
  end
end
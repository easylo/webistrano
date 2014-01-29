#alimaher
class AddHostConfiguration < ActiveRecord::Migration
  def self.up
  	 create_table "host_configurations", :force => true do |t|
  	end
  end

  def self.down
  	drop_table :host_configurations
  end
end
#end alimaher
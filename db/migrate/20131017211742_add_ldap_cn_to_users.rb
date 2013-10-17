#alimaher
class AddLdapCnToUsers < ActiveRecord::Migration
  def self.up
  	add_column :users, :ldap_cn, :string
  end

  def self.down
  	remove_column :users, :ldap_cn
  end
end
#end alimaher
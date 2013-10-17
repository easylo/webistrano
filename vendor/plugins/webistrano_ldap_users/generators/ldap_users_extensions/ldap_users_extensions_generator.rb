class LdapUsersExtensionsGenerator < Rails::Generator::Base
  
  def manifest
    #added files
    record do |m|
	m.migration_template 'add_ldap_cn_to_users.rb', 'db/migrate', :migration_file_name => "add_ldap_cn_to_users"
      
     m.gsub_file 'app/models/user.rb', /(#{Regexp.escape("require 'digest/sha1'")})/mi do |match|
        "#{match}\n
	require 'rubygems'\n
	require 'net/ldap'\n"
      end

     m.gsub_file 'app/models/user.rb', /(#{Regexp.escape("class User < ActiveRecord::Base")})/mi do |match|
        "#{match}\n
	attr_accessible :ldap_cn\n
	def self.retrieve_from_ldap(login)\n
		auth = { :method =>  WebistranoConfig[:ldap_method], :username =>  WebistranoConfig[:ldap_username], :password =>  WebistranoConfig[:ldap_password] }\n
		ldap = Net::LDAP.new  :host => WebistranoConfig[:ldap_host], :port => WebistranoConfig[:ldap_port], :base => WebistranoConfig[:ldap_base], :auth => auth\n
		filter = Net::LDAP::Filter.eq('cn', login)\n
		ldap_entry = ldap.search(:filter => filter).first\n
		return ldap_entry\n
	end\n
	def ldap_authenticated?(password)\n
		auth = { :method =>  WebistranoConfig[:ldap_method], :username =>  WebistranoConfig[:ldap_username], :password =>  WebistranoConfig[:ldap_password] }\n		
		ldap = Net::LDAP.new  :host => WebistranoConfig[:ldap_host], :port => WebistranoConfig[:ldap_port], :base => WebistranoConfig[:ldap_base],:auth => auth\n
		ldap_entry = User.retrieve_from_ldap(ldap_cn)\n
		dn=ldap_entry.dn\n
		ldap.auth(dn,password)\n
		ldap.bind\n
	end\n
	def self.ldap_users\n
		auth = { :method =>  WebistranoConfig[:ldap_method], :username =>  WebistranoConfig[:ldap_username], :password =>  WebistranoConfig[:ldap_password] }\n
		ldap = Net::LDAP.new  :host => WebistranoConfig[:ldap_host], :port => WebistranoConfig[:ldap_port], :base => WebistranoConfig[:ldap_base], :auth => auth\n
		filter = Net::LDAP::Filter.eq(WebistranoConfig[:ldap_filter_attr], WebistranoConfig[:ldap_filter_value] )\n
		entries = ldap.search(:filter => filter)\n
		entries.delete_if{|u| u[:cn] == [] || u[:mail] == []}\n
		return entries\n
	end\n
	def self.ldap_email(ldap_cn)\n
		auth = { :method =>  WebistranoConfig[:ldap_method], :username =>  WebistranoConfig[:ldap_username], :password =>  WebistranoConfig[:ldap_password] }\n
		ldap = Net::LDAP.new  :host => WebistranoConfig[:ldap_host], :port => WebistranoConfig[:ldap_port], :base => WebistranoConfig[:ldap_base], :auth => auth\n
		filter = Net::LDAP::Filter.eq('cn', ldap_cn)\n
		ldap_entry = ldap.search(:filter => filter).first\n
		return ldap_entry[:mail].to_s\n
	end\n
	def normalize\n
		if self.login.blank?\n
			self.login = User.ldap_email(self.ldap_cn)\n
			self.email = User.ldap_email(self.ldap_cn)\n
			if(self.email.blank?)\n
				self.login = self.ldap_cn\n				
				self.email = \"\#{self.login}@empty.com\"\n
			end\n 
			self.password = '----'\n
			self.password_confirmation = '----'\n
		else\n
			self.ldap_cn = nil\n
		end\n
	end\n"
      end
     m.gsub_file 'app/models/user.rb', /(#{Regexp.escape("u && u.authenticated?(password) ? u : nil")})/mi do |match|
        "u && (u.authenticated?(password) || u.ldap_authenticated?(password)) ? u : nil"
      end
     m.gsub_file 'app/controllers/users_controller.rb', /(#{Regexp.escape("@user = User.new(params[:user])")})/mi do |match|
        "#{match}\n@user.normalize\n"
      end


     m.gsub_file 'app/controllers/users_controller.rb', /def edit\s+\@user = User.find\(params\[:id\]\)/mi do |match|
        "#{match}\n
	if !@user.ldap_cn.blank?\n
    		@user.login = nil\n
    		@user.email = nil\n
	end\n"
      end

	m.gsub_file 'app/controllers/users_controller.rb', /(#{Regexp.escape("@user.attributes = params[:user]")})/mi do |match|
        "#{match}\n@user.normalize\n"
      	end

	#webistrano_config
	#24
	m.gsub_file 'config/webistrano.yml.sample', /(#{Regexp.escape(":authentication_method: cas")})/mi do |match|
		"#{match}\n 
		:ldap_host => \"192.168.0.5\",\n
		:ldap_port => 389,\n
		:ldap_base => \"ou=people,dc=example,dc=com\",\n
		:ldap_method => :simple, \#either :simple or :anonymous. If you choose :anonymous then you can keep username/password empty ''\n
	  	:ldap_username =>'cn=admin,dc=exampl,dc=com',\n 
	  	:ldap_password =>'password',
		:ldap_filter_attr => 'objectclass', \#any ldap entry attribute\n
		:ldap_filter_value => 'person',\#the value of the attribute to be filtered on\n" 
	end	
  		
      
      #18
      m.template 'views/_form.html.erb', 'app/views/users/_form.html.erb'
    
    end
  end
  
end

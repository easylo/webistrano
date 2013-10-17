require 'digest/sha1'

	require 'rubygems'

	require 'net/ldap'

class User < ActiveRecord::Base

	attr_accessible :ldap_cn

	def self.retrieve_from_ldap(login)

		auth = { :method =>  WebistranoConfig[:ldap_method], :username =>  WebistranoConfig[:ldap_username], :password =>  WebistranoConfig[:ldap_password] }

		ldap = Net::LDAP.new  :host => WebistranoConfig[:ldap_host], :port => WebistranoConfig[:ldap_port], :base => WebistranoConfig[:ldap_base], :auth => auth

		filter = Net::LDAP::Filter.eq('cn', login)

		ldap_entry = ldap.search(:filter => filter).first

		return ldap_entry

	end

	def ldap_authenticated?(password)

		if ldap_cn.nil? then
      			false
    		else
			auth = { :method =>  WebistranoConfig[:ldap_method], :username =>  WebistranoConfig[:ldap_username], :password =>  WebistranoConfig[:ldap_password] }
		
			ldap = Net::LDAP.new  :host => WebistranoConfig[:ldap_host], :port => WebistranoConfig[:ldap_port], :base => WebistranoConfig[:ldap_base],:auth => auth

			ldap_entry = User.retrieve_from_ldap(ldap_cn)

			dn=ldap_entry.dn

			ldap.auth(dn,password)

			ldap.bind

		end
	end

	def self.ldap_users

		if WebistranoConfig[:ldap_enable]  then

			auth = { :method =>  WebistranoConfig[:ldap_method], :username =>  WebistranoConfig[:ldap_username], :password =>  WebistranoConfig[:ldap_password] }

			ldap = Net::LDAP.new  :host => WebistranoConfig[:ldap_host], :port => WebistranoConfig[:ldap_port], :base => WebistranoConfig[:ldap_base], :auth => auth

			filter = Net::LDAP::Filter.eq(WebistranoConfig[:ldap_filter_attr], WebistranoConfig[:ldap_filter_value] )

			entries = ldap.search(:filter => filter)

			entries.delete_if{|u| u[:cn] == [] || u[:mail] == []}
    		else
      			entries = Array.new 
		end

		return entries

	end

	def self.ldap_email(ldap_cn)

		auth = { :method =>  WebistranoConfig[:ldap_method], :username =>  WebistranoConfig[:ldap_username], :password =>  WebistranoConfig[:ldap_password] }

		ldap = Net::LDAP.new  :host => WebistranoConfig[:ldap_host], :port => WebistranoConfig[:ldap_port], :base => WebistranoConfig[:ldap_base], :auth => auth

		filter = Net::LDAP::Filter.eq('cn', ldap_cn)

		ldap_entry = ldap.search(:filter => filter).first

		return ldap_entry[:mail].to_s

	end

	def normalize

		if self.login.blank?

			self.login = self.ldap_cn

			self.email = User.ldap_email(self.ldap_cn)

			if(self.email.blank?)

				self.login = self.ldap_cn
				
				self.email = "#{self.login}@empty.com"

			end
 
			self.password = '----'

			self.password_confirmation = '----'

		else

			self.ldap_cn = nil

		end

	end

  has_many :deployments, :dependent => :nullify, :order => 'created_at DESC'
  has_and_belongs_to_many :projects
  has_many :stages_user
  has_many :stages, :through => :stages_user

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  attr_accessible :login, :email, :password, :password_confirmation, :time_zone, :tz

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password

  named_scope :enabled, :conditions => {:disabled => nil}
  named_scope :disabled, :conditions => "disabled IS NOT NULL"

  def validate_on_update
    if User.find(self.id).admin? && !self.admin?
      errors.add('admin', 'status can no be revoked as there needs to be one admin left.') if User.admin_count == 1
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login_and_disabled(login, nil) # need to get the salt
    u && (u.authenticated?(password) || u.ldap_authenticated?(password)) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def admin?
    self.admin.to_i == 1
  end

  def revoke_admin!
    self.admin = 0
    self.save!
  end

  def make_admin!
    self.admin = 1
    self.save!
  end

  def self.admin_count
    count(:id, :conditions => ['admin = 1 AND disabled IS NULL'])
  end

  def recent_deployments(limit=3)
    self.deployments.find(:all, :limit => limit, :order => 'created_at DESC')
  end

  def disabled?
    !self.disabled.blank?
  end

  def disable
    self.update_attribute(:disabled, Time.now)
    self.forget_me
  end

  def enable
    self.update_attribute(:disabled, nil)
  end

  def read_only(stage)
    su = stages_user.find_by_stage_id(stage.id)
    return su.read_only? if su
    return false
   end

  def access(stage)
    (stages_user.find_by_stage_id(stage.id).read_only?)? 'read only' : 'full access'
  end

  def project_stages(project)
    return stages if !stages
    stages.select{|stage| stage.project.id == project.id}
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      WebistranoConfig[:authentication_method] != :cas && (crypted_password.blank? || !password.blank?)
    end
end

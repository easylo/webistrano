class Host < ActiveRecord::Base
  has_many :roles, :dependent => :destroy, :uniq => true
  has_many :stages, :through => :roles, :uniq => true # XXX uniq does not seem to work! You get all stages, even doubles
  has_many :configuration_parameters, :dependent => :destroy, :class_name => "HostConfiguration", :order => 'id ASC'


  validates_uniqueness_of :name
  validates_presence_of :name
  validates_length_of :name, :maximum => 250
 
  attr_accessible :name, :alias

  before_validation :strip_whitespace, :name_alias_if_empty

  # returns a string with all custom tasks to be loaded by the Capistrano config
  def tasks
    #HostConfiguration.templates[template]::TASKS
  end

  def strip_whitespace
    self.name = self.name.strip rescue nil
  end

  def name_alias_if_empty
    if self.alias.empty?
      self.alias = self.name
    end
  end

  def validate
    errors.add("name", "is not a valid hostname or IP") unless ( valid_ip? || valid_hostname? )
  end

  def valid_hostname?
    self.name =~ /\A[a-zA-Z0-9\_\-\.]+\Z/
  end

  def valid_ip?
    if self.name =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
      ($1.to_i <= 255) && ($2.to_i <= 255) && ($3.to_i <= 255) && ($4.to_i <= 255)
    else
      false
    end
  end

end

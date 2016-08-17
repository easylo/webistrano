# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.18' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'

  config.gem 'capistrano'
  config.gem 'open4'
  config.gem 'syntax'
end

require 'open4'
require 'capistrano/cli'
require 'syntax/convertors/html'
require 'composite_primary_keys'

# delete cached stylesheet on boot in order to delete stale versions
File.delete("#{RAILS_ROOT}/public/stylesheets/application.css") if File.exists?("#{RAILS_ROOT}/public/stylesheets/application.css")

# set default time_zone to UTC
ENV['TZ'] = 'UTC'
Time.zone = 'UTC'

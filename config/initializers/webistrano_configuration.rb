WebistranoConfig = YAML.load_file("#{RAILS_ROOT}/config/webistrano.yml")

if WebistranoConfig[:authentication_method] == :cas
  cas_options = YAML::load_file(RAILS_ROOT+'/config/cas.yml')
  CASClient::Frameworks::Rails::Filter.configure(cas_options[RAILS_ENV])
end

WEBIFONY_VERSION = '0.9'

ActionMailer::Base.delivery_method = WebistranoConfig[:smtp_delivery_method]
ActionMailer::Base.smtp_settings = WebistranoConfig[:smtp_settings]

Notification.webistrano_sender_address = WebistranoConfig[:webistrano_sender_address]

ExceptionNotification::Notifier.exception_recipients = WebistranoConfig[:exception_recipients]
ExceptionNotification::Notifier.sender_address = WebistranoConfig[:exception_sender_address]

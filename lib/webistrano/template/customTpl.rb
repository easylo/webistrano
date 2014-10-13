module Webistrano
  module Template
    module customTpl

      CONFIG = Webistrano::Template::Symfony2::CONFIG.dup.merge({
        :symfony_env_local => 'dev',
        :symfony_env_prod => 'prod',
        :php_bin => '/usr/bin/php',
        :remote_tmp_dir => '/tmp',
        :app_path => "app",
        :web_path => "web",
        :app_config_file => "parameters.yml",
        :update_assets_version => false,
        :clear_controllers => true,
        :use_composer => true,
        :copy_vendors => true,
        :dump_assetic_assets => true,
        :assets_symlinks => true,
        :update_assets_version => true,
        :clear_controllers => true,
        :permission_method => ":acl",
        :use_set_permissions => true,
        :default_environment_PATH => '$PATH',
        :after_deploy_cleanup_old_releases => true
      }).freeze

      DESC = <<-'EOS'
        Template to use for custom TPL project to deploy with capifony.
        based on sf2
      EOS

      # load all capifony Symfony2 tasks
      task = ""
      task = task + File.open("lib/webistrano/template/symfony2.rb", "rb").read
      capifony = [ "capifony", "symfony2/symfony", "symfony2/database", "symfony2/deploy", "symfony2/doctrine", "symfony2/propel", "symfony2/web" ]
      capifony.each {|import|
        task = task + File.open("lib/webistrano/template/capifony/lib/#{import}.rb", "rb").read
      }




    end
  end
end

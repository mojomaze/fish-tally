# A Capistrano deploy configuration file for non-Rails applications
# on a server using Bundler for gem management and rbenv for rubies.

# Ideally you create an nginx.server.conf file inside the project
# which is symlinked to /etc/nginx/sites-available via a task below.

# Runs bundler commands on deployment
require "bundler/capistrano"

# Load rvm
set :default_environment, {
  "PATH" => "/usr/local/rvm/gems/ruby-1.9.3-p392/bin:/usr/local/rvm/gems/ruby-1.9.3-p392@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p392/bin:/usr/local/rvm/bin:$PATH"
}

set :rvm_ruby_string, 'ruby-1.9.3-p392'
set :rvm_type, :system

# Application name
set :application, "fish-tally"
# The user to deploy as
set :user, "deploy"
# Don't use sudo when running the commands
set :use_sudo, false

# Required for sudo password prompt on config symlinking
default_run_options[:pty] = true

# Forward public keys for GitHub etc. authentication.
# Prevents us having deployment server public keys.
ssh_options[:forward_agent] = true

# Use git, set the repo
set :scm, :git
set :repository,  "git@github.com:mojomaze/fish-tally.git"

# Put the app in this directory
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
 
# server roles
# DOMAIN can be an IP or FQDN
server "198.199.66.35", :web, :app, :db, primary: true

# After an initial (cold) deploy, symlink the app and restart nginx
after "deploy:cold" do
  admin.symlink_config
  admin.nginx_restart
end

# As this isn't a rails app, we don't start and stop the app invidually
namespace :deploy do
  desc "Not starting as we're running passenger."
  task :start do
  end

  desc "Not stopping as we're running passenger."
  task :stop do
  end

  desc "Restart the app."
  task :restart, roles: :app, except: { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end

# These task are used for un/symlinking the app, and restarting the server (nginx)
namespace :admin do
  desc "Link the server config to nginx."
  task :symlink_config, roles: :app do
    run "#{sudo} ln -nfs #{deploy_to}/current/config/nginx.server /opt/nginx/sites-enabled/#{application}"
  end

  desc "Unlink the server config."
  task :unlink_config, roles: :app do
    run "#{sudo} rm /opt/nginx/sites-enabled/#{application}"
  end

  desc "Restart nginx."
  task :nginx_restart, roles: :app do
    run "#{sudo} service nginx restart"
  end
end
require 'rvm/capistrano'
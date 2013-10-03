require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require "whenever/capistrano"

set :application, "sapphire"

set :scm, :git
set :repository, "git@github.com:matthee/Sapphire.git"

set :user, :sapphire
set :use_sudo, false

default_run_options[:shell] = '/bin/zsh -i'
set :rvm_ruby_string, :local

set :deploy_via, :remote_cache
set :deploy_to, "/home/sapphire/#{application}"
set :stages, %w(staging production)
set :default_stage, "staging"

set :whenever_environment, defer { stage }

###############################################################################

after 'deploy:update_code' do
  deploy.replace_secret
  deploy.symlink_shared_folders
  deploy.setup_mail_config
  deploy.setup_database_config
  deploy.migrate

  deploy.cleanup
end

after "deploy:setup" do
  deploy.setup_shared_folders
end

load 'deploy/assets'


###############################################################################

namespace :deploy do
  shared_folders = ["public/assets", "uploads", "emails"]

  desc "Start, shows ruby version"
  task :start do
    run "ruby -v"
  end

  desc "Stop"
  task :stop do ; end

  desc "Restart rails hosting webserver"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  namespace :db do
    desc "Load the seed data from db/seeds.rb"
    task :seed do
      run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake db:seed"
    end

    desc "Reset the database"
    task :reset do
      run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake db:reset"
    end
  end

  desc "Updates the secret_key_base for cookies"
  task :replace_secret do
    run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake secret:update"
  end

  desc "Setup mail config file in shared_path"
  task :setup_mail_config do
    run "ln -nfs #{shared_path}/config/mail.yml #{release_path}/config/mail.yml"
  end

  desc "Setup database config file in shared_path"
  task :setup_database_config do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Create shared folders in shared_path"
  task :setup_shared_folders do
    shared_folders.each do |folder|
      run "mkdir -p #{shared_path}/#{folder}"
    end
  end

  desc "Create symlinks for shared folders in current_path"
  task :symlink_shared_folders do
    shared_folders.each do |dir|
      run "rm -rf #{current_path}/#{dir}"
      run "ln -nfs #{shared_path}/#{dir} #{release_path}/#{dir}"
    end
  end
end

desc "Tails the production log file"
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

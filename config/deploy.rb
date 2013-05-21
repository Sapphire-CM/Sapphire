require 'capistrano/ext/multistage'

set :application, "sapphire"
set :repository, "git@github.com:matthee/Sapphire.git"

set :scm, :git
set :user, "sapphire"
set :use_sudo, false

default_run_options[:shell] = '/bin/zsh -i'
set :rvm_ruby_string, :local

set :deploy_via, :remote_cache
set :deploy_to, "/home/sapphire/#{application}"
set :stages, %w(staging production)
set :default_stage, "staging"

namespace :deploy do
  shared_folders = ["public/assets"]

  task :start do
    run "ruby -v"
  end

  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :seed do
    run "cd #{current_release} && RAILS_ENV=#{rails_env} rake db:seed"
  end

  task :migrate do
    run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
  end

  task :replace_secret do
    run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake secret:update"
  end

  task :setup_database_config do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task :setup_shared_folders do
    shared_folders.each do |folder|
      run "mkdir -p #{shared_path}/#{folder}"
    end
  end

  task :symlink_shared_folders do
    shared_folders.each do |dir|
      run "rm -rf #{current_path}/#{dir}"
      run "ln -nfs #{shared_path}/#{dir} #{release_path}/#{dir}"
    end
  end
end

namespace :assets do
  desc "Clean and Precompile new assets"
  task :update do
    assets.clean
    assets.precompile
  end

  desc "Remove compiled assets"
  task :clean do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:clean"
  end

  desc "Compile all the assets named in config.assets.precompile"
  task :precompile do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
  end
end

namespace :bundler do
  task :bundle_new_release, :roles => :app do
    run "cd #{release_path} && bundle --without development test"
  end
end

task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

after 'deploy:update_code' do
  bundler.bundle_new_release

  # deploy:replace_secret
  deploy.setup_database_config
  deploy.migrate

  assets.precompile

  deploy.cleanup
end

after "deploy:setup" do
  deploy.setup_shared_folders
end

before "assets:precompile" do
  deploy.symlink_shared_folders
end


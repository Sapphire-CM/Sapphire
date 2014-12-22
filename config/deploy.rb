set :application, 'sapphire'
set :deploy_to, "/home/sapphire/#{fetch(:application)}"

set :repo_url, 'git@github.com:matthee/Sapphire.git'
set :scm, :git
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"

set :stages, %w(staging production)

set :linked_files, %w{config/database.yml config/mail.yml}
set :linked_dirs, %w{log emails uploads persistent tmp/pids}

set :log_level, :info

set :bundle_binstubs, nil

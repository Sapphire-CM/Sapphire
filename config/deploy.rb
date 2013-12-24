set :application, 'sapphire'
set :deploy_to, "/home/sapphire/#{fetch(:application)}"

set :repo_url, 'git@github.com:matthee/Sapphire.git'
set :scm, :git

set :stages, %w(staging production)

set :linked_files, %w{config/database.yml config/mail.yml}
set :linked_dirs, %w{bin log emails uploads persistent}

set :log_level, :debug

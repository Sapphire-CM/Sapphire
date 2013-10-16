set :application, 'sapphire'
set :repo_url, 'git@github.com:matthee/Sapphire.git'
set :scm, :git

set :deploy_to, "/home/sapphire/#{fetch(:application)}"
set :deploy_via, :copy

set :stages, %w(staging production)

set :linked_files, %w{config/database.yml config/mail.yml}
set :linked_dirs, %w{bin log emails uploads persistent}

set :log_level, :debug

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :finishing, 'deploy:cleanup'

  namespace :db do
    desc 'Drops the database to an empty state'
    task :drop do
      on primary :db do
        within release_path do
          with rails_env: fetch(:stage) do
            execute :rake, "db:drop"
          end
        end
      end
    end
    before :drop, 'rvm:hook'

    desc 'Resets the database to an empty state'
    task :reset do
      on primary :db do
        within release_path do
          with rails_env: fetch(:stage) do
            execute :rake, "db:reset"
          end
        end
      end
    end
    before :reset, 'rvm:hook'

    desc "Load the seed data from db/seeds.rb"
    task :seed do
      on primary :db do
        within release_path do
          with rails_env: fetch(:stage) do
            execute :rake, "db:seed"
          end
        end
      end
    end
    before :seed, 'rvm:hook'

    desc "Updates the secret_key_base for cookies"
    task :seed do
      on primary :db do
        within release_path do
          with rails_env: fetch(:stage) do
            execute :rake, "secret:update"
          end
        end
      end
    end
    before :seed, 'rvm:hook'

  end
end

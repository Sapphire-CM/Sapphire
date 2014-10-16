require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/rvm'
require 'capistrano/rails'
require 'capistrano/sidekiq'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  after :publishing, 'deploy:restart'

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
  end
end

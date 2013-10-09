set :application, 'sapphire'
set :repo_url, 'git@github.com:matthee/Sapphire.git'
set :scm, :git

set :deploy_to, "/home/sapphire/#{fetch(:application)}"
set :deploy_via, :copy

set :stages, %w(staging production)

set :linked_files, %w{config/database.yml config/mail.yml}
set :linked_dirs, %w{bin log emails uploads persitent}

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

  end
end

# desc "Updates the secret_key_base for cookies"
# task :replace_secret do
#   run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake secret:update"
# end

# desc "Tails the production log file"
# task :tail_logs, :roles => :app do
#   run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
#     puts  # for an extra line break before the host name
#     puts "#{channel[:host]}: #{data}"
#     break if stream == :err
#   end
# end

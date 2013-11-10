source 'https://rubygems.org'

gem 'rails', '4.0'

gem 'sqlite3'
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'simple_form', '~> 3.0'       # forms
gem 'carrierwave'                 # fileuploads
gem 'squeel', '~> 1.1'            # easy DSL
gem 'draper'                      # decorators
gem 'kaminari'                    # pagination
gem 'flash_render'                # render method with notice/alerts
gem 'devise', '~> 3.1.0'          # user authentication
gem 'cancan'                      # role based ability management for users
gem 'turbolinks'                  # Turbolinks makes following links in your web application faster
gem 'jquery-turbolinks'           # Turbolinks jquery plugin for DOM ready events
gem 'ranked-model'                # manages sort-position of ratings

gem 'compass-rails',   '~> 2.0.alpha'   # Compass intregration into assets-pipeline
gem 'sass-rails',      '~> 4.0'   # Use SCSS for stylesheets
gem 'coffee-rails',    '~> 4.0'   # Use CoffeeScript for .js.coffee assets and views
gem 'uglifier',        '>= 1.3'   # Use Uglifier as compressor for JavaScript assets
gem 'jquery-rails'                # Use jquery as the JavaScript library
gem 'jquery-mousewheel-rails'     # jquery MouseWheel support

gem 'zurb-foundation', '~> 4.3.0'
gem 'foundation-icons-sass-rails', '~> 3.0'

gem 'remotipart', '~> 1.2'        # fileuploads via ajax

gem 'whenever'                    # cron tasks
gem 'mail'                        # fetching, delivering and parsing of emails

group :production do
  gem 'therubyracer'
  gem 'pg'                        # PostgreSQL database connector
end

group :development do
  gem 'guard'
  gem 'guard-pow'
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-plus'

  gem 'spring'
  gem 'spring-commands-cucumber'

  gem 'capistrano', '~> 3.0'          # deployment via ssh
  gem 'capistrano-bundler', github: 'capistrano/bundler'
  gem 'capistrano-rails', github: 'capistrano/rails'
  gem 'capistrano-rvm', github: 'capistrano/rvm'

  gem 'thin'                # small development webserver
  gem 'debugger'            # debugger with irb, 1.9.3-only
  gem 'byebug'              # debugger with irb, 2.0.0-only
  gem 'better_errors'       # pretty error pages
  gem 'binding_of_caller'   # interactive shell within error pages
  gem 'brakeman'            # common security problems checker
  gem 'awesome_print'       # nicley formatted object inspection
  gem 'bullet'              # logs and supposes optimizations for db queries
  gem 'sextant'             # route /rails/routes for displaying all routes
  gem 'quiet_assets'        # suppresses logging of assets files
  gem 'rails-erd'           # Entity-Relation Diagrams of models
  gem 'letter_opener'       # local email sender to HTML pages
end

group :development, :test do
  gem 'cucumber'
  gem 'cucumber-rails', require:false
  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

############################
#  migration to Rails 4.0  #
############################
#
gem 'protected_attributes'
#
############################
#       end migration      #
############################

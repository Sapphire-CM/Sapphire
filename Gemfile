source 'https://rubygems.org'

gem 'rails', '4.0.0'

gem 'sqlite3'
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'simple_form', '~> 3.0.0.rc'  # forms
gem 'carrierwave'                 # fileuploads
gem 'squeel', :git => "https://github.com/ernie/squeel.git"                      # easy DSL
gem 'draper'                      # decorators
gem 'kaminari'                    # pagination
gem 'flash_render'                # render method with notice/alerts
gem 'devise', '~> 3.0.0.rc'       # user authentication
gem 'cancan'                      # role based ability management for users
gem 'turbolinks'                  # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'jquery-turbolinks'           # turbolinks jquery plugin for events
gem 'ranked-model', :git => "https://github.com/mixonic/ranked-model.git", :branch => "rails4"                # manages sort-position of ratings

gem 'compass-rails', :git => "https://github.com/Compass/compass-rails.git", :branch => "rails4-hack"
gem 'sass-rails',      '~> 4.0.0' # Use SCSS for stylesheets
gem 'coffee-rails',    '~> 4.0.0' # Use CoffeeScript for .js.coffee assets and views
gem 'uglifier',        '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'jquery-rails'                # Use jquery as the JavaScript library

gem 'zurb-foundation', '>= 4.0'
gem "foundation_icons_rails", "~> 1.0.1"

group :production do
  gem 'therubyracer'
  gem 'pg'                        # PostgreSQL database connector
end

group :development do
  gem 'thin'                # small development webserver
  gem 'debugger'            # debugger with irb, 1.9.3-only
  gem 'better_errors'       # pretty error pages
  gem 'binding_of_caller'   # interactive shell within error pages
  gem 'brakeman'            # common security problems checker
  gem 'awesome_print'       # nicley formatted object inspection
  gem 'capistrano'          # deployment via ssh
  gem 'bullet'              # logs and supposes optimizations for db queries
  gem 'sextant'             # route /rails/routes for displaying all routes
end

group :development, :test do
  gem 'rspec-rails'
  gem 'cucumber-rails', require:false
  gem 'capybara'
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

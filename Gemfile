source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'simple_form'          # forms
gem 'carrierwave'          # fileuploads
gem 'squeel'               # easy DSL
gem 'draper'               # decorators
gem 'kaminari'             # pagination
gem 'flash_render'         # render method with notice/alerts
gem 'devise'               # user authentication
gem 'cancan'               # role based ability management for users
gem 'turbolinks'           # ajax replacement links
gem 'jquery-turbolinks'    # turbolinks jquery plugin for events
gem 'ranked-model'         # manages sort-position of ratings

group :production do
  gem 'therubyracer'
  gem 'pg'                 # postgres connector
end

group :development do
  gem 'thin'               # webserver
  gem 'debugger'           # debugger with irb, 1.9.3-only
  gem 'better_errors'      # pretty error pages
  gem 'binding_of_caller'  # interactive shell within error pages
  gem 'sextant'            # /rails/routes for displaying all routes
  gem 'brakeman'           # common security problems checker
  gem 'awesome_print'      # nicley formatted object inspection
  gem 'capistrano'         # deployment
  gem 'bullet'             # logs and supposes optimizations for db queries
end

group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'compass-rails'
  gem 'uglifier'

  gem 'zurb-foundation', '>= 4.0'
  gem 'foundation-icons-sass-rails'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_girl'
end

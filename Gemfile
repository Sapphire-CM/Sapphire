source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem "simple-navigation"
gem 'simple_form'       # forms
gem 'carrierwave'       # fileuploads
gem 'squeel'            # easy DSL
gem 'draper'            # decorators
gem 'kaminari'          # pagination
gem 'flash_render'      # render method with notice/alerts
gem 'devise'            # user authentication
gem 'cancan'            # role based ability management for users
# gem 'date-input-rails'  # input-tag for date type
gem 'modernizr'         # needed for date-input-rails
gem 'turbolinks'        # ajax replacement links
gem 'jquery-turbolinks' # turbolinks jquery plugin for events

group :production do
  gem 'therubyracer'
  gem 'pg'
end

group :development do
  gem 'thin'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'sextant'            # /rails/routes for displaying all routes
  gem 'brakeman'           # common security problems checker
  gem 'awesome_print'      # nicley formatted object inspection
  gem 'capistrano'         # deployment
end

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'

  gem 'compass-rails'
  gem 'zurb-foundation', '>= 4.0'
  gem 'foundation-icons-sass-rails'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_girl'
end
